//
//  ZZScrollView.swift
//  AppleVineger
//
//  Created by CZZ on 2020/7/21.
//  Copyright © 2020 czz. All rights reserved.
//

import UIKit
import WebKit

open class ZZScrollView: UIScrollView {

    public class Item: NSObject {
        public init(view: UIView, inset: UIEdgeInsets = .zero, minHeight: CGFloat = 0, fixedWidth: CGFloat = 0) {
            super.init()
            self.view = view
            self.inset = inset
            self.minHeight = minHeight
            self.fixedWidth = fixedWidth
            self.addObserver()
        }

        deinit {
            self.removeObserver()
        }

        private(set) public var minHeight: CGFloat = 0
        private(set) public var fixedWidth: CGFloat = 0 // 与inset 冲突  当大于0 时 inset left right 失效
        private(set) public var view: UIView!
        @objc public dynamic var inset: UIEdgeInsets = .zero
        @objc private(set) public dynamic var contentSize: CGSize = .zero

        private func addObserver(){
            if self.view is UIScrollView{
                let scView = self.view as! UIScrollView
                scView.isScrollEnabled = false
                scView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old], context: nil)
                self.contentSize = scView.contentSize
            }else if self.view is WKWebView{
                let webView = self.view as! WKWebView
                webView.scrollView.isScrollEnabled = false
                webView.addObserver(self, forKeyPath: "scrollView.contentSize", options: [.new, .old], context: nil)
                self.contentSize = webView.scrollView.contentSize
            }else{
                self.view.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
                self.contentSize = self.view.frame.size
            }
        }

        private func removeObserver(){
            if self.view is UIScrollView{
                let scView = self.view as! UIScrollView
                scView.removeObserver(self, forKeyPath: "contentSize", context: nil)
            }else if self.view is WKWebView{
                let webView = self.view as! WKWebView
                webView.removeObserver(self, forKeyPath: "scrollView.contentSize", context: nil)
            }else{
                self.view.removeObserver(self, forKeyPath: "frame", context: nil)
            }
        }

        public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            switch keyPath {
                case "contentSize":
                    let scView = self.view as! UIScrollView
                    self.contentSize = scView.contentSize
                    break
                case "scrollView.contentSize":
                    let webView = self.view as! WKWebView
                    self.contentSize = webView.scrollView.contentSize
                    break
                default:
                    self.contentSize = self.view.frame.size
                    break
            }
        }
    }

    deinit {
        self.removeObserver(self, forKeyPath: "contentOffset", context: nil)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self._init()
    }

    public init(items: [Item] = []) {
        super.init(frame: .zero)
        self.items = items
        self._init()
        self.addItems()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self._init()
    }

    private func _init(){
        self.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
    }

    open var items: [Item] = []{
        willSet{
            self.items.forEach({
                $0.removeObserver(self, forKeyPath: "contentSize", context: nil)
                $0.removeObserver(self, forKeyPath: "inset", context: nil)
                $0.view.removeFromSuperview()
            })
        }
        didSet{
            self.addItems()
        }
    }

    private func addItems(){
        self.items.forEach({
            self.addSubview($0.view)
            $0.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
            $0.addObserver(self, forKeyPath: "inset", options: [.old, .new], context: nil)
        })
        self.refreshOffset()
    }
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.refreshOffset()
    }

    open func refreshOffset(){
        let offset = self.contentOffset.y
        /*
         1、contentSize.height 在页面内 跟着父窗体滚动
         2、contentSize.height 超出了界面 滚动子窗体。当子窗体滚动位置在界面中完全显示之后跟着父窗体滚动
         */
        var totalHeight: CGFloat = 0
        self.items.forEach({ item in
            var viewHeight = item.contentSize.height
            var y = totalHeight + item.inset.top
            if (item.view is UIScrollView || item.view is WKWebView) && offset > 0{
                if viewHeight > self.frame.height{
                    viewHeight = self.frame.height
                }
                var scView: UIScrollView?
                if item.view is UIScrollView{
                    scView = item.view as? UIScrollView
                }else if item.view is WKWebView{
                    scView = (item.view as? WKWebView)?.scrollView
                }

                if offset >= (totalHeight + item.inset.top) && offset < (totalHeight + item.contentSize.height + item.inset.bottom - viewHeight){
                    y = offset
                    if (offset - totalHeight - item.inset.top) <= (item.contentSize.height - viewHeight){
                        let subOffset = offset - totalHeight - item.inset.top
                        scView?.contentOffset = CGPoint(x: 0, y: subOffset)
                    }else{
                        scView?.contentOffset = .zero
                    }
                }else if offset >= (totalHeight + item.contentSize.height - viewHeight + item.inset.bottom) && offset <= (totalHeight + item.contentSize.height + item.inset.bottom){
                    y = (item.contentSize.height - viewHeight) + totalHeight + item.inset.top
                    let subOffset = item.contentSize.height - viewHeight
                    scView?.contentOffset = CGPoint(x: 0, y: subOffset)
                }else{
                    scView?.contentOffset = .zero
                }
            }
            var viewX:CGFloat = item.inset.left
            if viewHeight < item.minHeight { viewHeight = item.minHeight }
            var viewWidth: CGFloat = self.frame.width - item.inset.left - item.inset.right
            if item.fixedWidth > 0 {
                viewWidth = item.fixedWidth
                viewX = (self.frame.width - viewWidth) / 2
            }
            
            let newFrame = CGRect(x: viewX, y: y, width: viewWidth, height: viewHeight)
            if item.view.frame != newFrame{
                item.view.frame = newFrame
            }
            totalHeight += (item.contentSize.height + item.inset.top + item.inset.bottom)
        })
        let newContentSize = CGSize(width: self.frame.width, height: totalHeight)
        if self.contentSize != newContentSize{
            self.contentSize = newContentSize
        }

    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.refreshOffset()
    }

}
