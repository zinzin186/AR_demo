//
//  ViewController.swift
//  TestAR
//
//  Created by Din Vu Dinh on 04/04/2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }


    @objc private func handleTap() {
        UnityEmbedded.showUnity()
    }
}
