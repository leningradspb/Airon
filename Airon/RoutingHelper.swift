//
//  RoutingHelper.swift
//  Airon
//
//  Created by Eduard Kanevskii on 20.01.2023.
//


import UIKit
import FloatingPanel

protocol BottomSheetScrollable
{
    func getScrollView() -> UIScrollView
}

/**
 Компонент для отображения модальных окон в виде "шторок"
 */
class BottomSheetPresenter
{
    private var handler: BottomSheetHandler?
    
    private lazy var coveringWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = UIWindow.Level.alert
        window.rootViewController = UIViewController()
        return window
    }()
    
    @discardableResult
    func present(_ vc: UIViewController, root: UIViewController, shouldHideKeyboard: Bool = true) -> BottomSheetHandler
    {
        if shouldHideKeyboard {
            hideKeyboard()
        }
        
        //Закрываем текущую открытую модалку
        if let fpc = handler?.fpc//, fpc.isBeingPresented
        {
            handler?.didRemove?()
            
            fpc.delegate = nil
            fpc.removePanelFromParent(animated: false)
        }
        
        handler = nil
        
        let fpc = FloatingPanelController()

        fpc.delegate = self
        fpc.surfaceView.cornerRadius = 16.0
        fpc.backdropView.backgroundColor = UIColor(hex: "#001326")
        fpc.surfaceView.grabberHandle.barColor = UIColor(hex: "#E2E5EB")
        fpc.isRemovalInteractionEnabled = true
        fpc.set(contentViewController: vc)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleBackdropTap))
        fpc.backdropView.addGestureRecognizer(tapGesture)

        if let scrollView = (vc as? BottomSheetScrollable)?.getScrollView()
        {
            fpc.track(scrollView: scrollView)
        }
        
        let handler = BottomSheetHandler()
        handler.vc = vc
        handler.fpc = fpc
        
        self.handler = handler
        coveringWindow.isHidden = false
        
//        if let root = coveringWindow.rootViewController
//        {
//            DispatchQueue.main.async
//            {
//                fpc.addPanel(toParent: root, animated: true)
//                fpc.updateLayout()
//            }
//        }
        
        DispatchQueue.main.async
        {
            fpc.addPanel(toParent: root, animated: true)
            fpc.updateLayout()
        }
        
        return handler
    }
    
    func removeCurrentModalView(animated: Bool)
    {
        handler?.fpc?.removePanelFromParent(animated: true)
    }
    
    @objc private func handleBackdropTap()
    {
        handler?.fpc?.removePanelFromParent(animated: true)
    }
    
    private func hideKeyboard()
    {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController
        {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.view.endEditing(true)
        }
    }
}

final class BottomSheetHandler
{
    weak var vc: UIViewController?
    fileprivate weak var fpc: FloatingPanelController?
    
    var didRemove: (()->Void)?
    
    fileprivate var size: Size = .intrinsic
    
    func updateLayout()
    {
        fpc?.updateLayout()
    }
    
    func updateLayout(withDuration: TimeInterval)
    {
        UIView.animate(withDuration: withDuration)
        {
            self.fpc?.updateLayout()
        }
    }
    
    @discardableResult
    func cornerRadius(_ value: CGFloat) -> BottomSheetHandler
    {
        fpc?.surfaceView.cornerRadius = value
        return self
    }
    
    @discardableResult
    func full() -> BottomSheetHandler
    {
        self.size = .full
        return self
    }
    
    @discardableResult
    func intrinsic() -> BottomSheetHandler
    {
        self.size = .intrinsic
        return self
    }
    
    fileprivate enum Size
    {
        case full
        case half
        case intrinsic
    }
}

extension BottomSheetPresenter: FloatingPanelControllerDelegate
{
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout?
    {
        guard let size = handler?.size else { return nil }
        
        if size == .full
        {
            return PanelLayout()
        }
        
        guard vc.contentViewController != nil else { return nil }
        
        var contentHeight: CGFloat = 0
        
        if let scrollView = (handler?.vc as? BottomSheetScrollable)?.getScrollView()
        {
            contentHeight = scrollView.contentSize.height
        }
        else if let contentView = vc.contentViewController?.view
        {
            contentHeight = contentView.frame.height
        }
        
        let fpcHeight = vc.view.frame.height - vc.view.safeAreaInsets.top
        
        if contentHeight > fpcHeight
        {
            return PanelLayout()
        }
        
        return PanelIntrinsicLayout()
    }
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController)
    {
        vc.scrollView?.isScrollEnabled = false
    }

    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition)
    {
        vc.scrollView?.isScrollEnabled = true
    }
}

extension BottomSheetPresenter
{
    final class PanelLayout: FloatingPanelLayout
    {
        var initialPosition: FloatingPanelPosition {
            return .full
        }
        
        var supportedPositions: Set<FloatingPanelPosition>  {
            return [.full]
        }
        
        func insetFor(position: FloatingPanelPosition) -> CGFloat?
        {
            if position == .full
            {
                return 44
            }
            else
            {
                return nil
            }
        }
        
        func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
            return 0.3
        }
    }
    
    final class PanelIntrinsicLayout: FloatingPanelIntrinsicLayout
    {
        var initialPosition: FloatingPanelPosition {
            return .full
        }
        
        var supportedPositions: Set<FloatingPanelPosition>  {
            return [.full]
        }
        
        func insetFor(position: FloatingPanelPosition) -> CGFloat? {
            return nil
        }
        
        func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
            return 0.3
        }
    }
}

