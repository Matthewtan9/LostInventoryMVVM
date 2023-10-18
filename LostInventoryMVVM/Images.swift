//
//  VisionBoardImage.swift
//  VisionBoard
//
//  Created by macuser on 2023-08-31.
//

import SwiftUI

struct VisionBoardImage: View {
    let image: String
    var body: some View {
        Image(image)
            .resizable()
            .frame(width: 100,height: 100)
            .aspectRatio(contentMode: .fit)
            .cornerRadius(10)
    }
}

struct VisionBoardImage_Previews: PreviewProvider {
    static var previews: some View {
        VisionBoardImage(image: "1")
    }
}
