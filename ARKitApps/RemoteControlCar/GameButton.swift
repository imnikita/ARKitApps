//
//  GameButton.swift
//  ARKitApps
//
//  Created by Mykyta Popov on 29/08/2023.
//

import UIKit

class GameButton: UIButton {
    
    let callBack: () -> Void
    private var timer: Timer!
    
    init(frame: CGRect, callBack: @escaping () -> Void) {
        self.callBack = callBack
        super.init(frame: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] timer in
            self?.callBack()
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer.invalidate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
