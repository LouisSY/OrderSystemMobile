//
//  MenuImageView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 27/08/2024.
//

import PhotosUI
import SwiftUI

/// 用于上传网页菜单图片
struct MenuImageView: View {
    
    var body: some View {
        HStack {
            UploadMenuView(sectionTitle: "主电视")
            UploadMenuView(sectionTitle: "副电视")
        }
    }
}

struct UploadMenuView: View {
    var sectionTitle: String
    @State private var menuItem: PhotosPickerItem?
    @State private var menuImage: Image?
    @State private var menuData: Data?
    @State private var menuOnline: Image?
    
    var body: some View {
        VStack {
            // Title
            HStack {
                Image(systemName: "tv")
                Text(sectionTitle)
            }
            .padding()
            .font(.largeTitle)
            .frame(maxWidth: .infinity)
            .background()
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
            .shadow(radius: 10)
            .padding()
            
            // Original Menu Image on server
            if menuOnline != nil {
                menuOnline?
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    .opacity((menuImage != nil) ? 0.5 : 1)
            } else {
                let getMenuURL = NSLocalizedString(sectionTitle == "主电视" ? "getMenuImage1" : "getMenuImage2", comment: "URL for obtaining menu image")
                
                AsyncImage(url: URL(string: getMenuURL)) { menuOnline in
                    menuOnline
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                        .shadow(radius: 10)
                        .padding(.horizontal)
                        .opacity((menuImage != nil) ? 0.5 : 1)
                } placeholder: {
                    ProgressView {
                        Text("正在加载图片")
                    }
                    .frame(maxWidth: .infinity, maxHeight: 370)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                    .shadow(radius: 10)
                    .padding(.horizontal)
                }
            }
            
            // show an up arrow if an image has been selected
            Spacer()
            if menuImage != nil {
                Image(systemName: "arrow.up")
                    .font(.title2)
            }
            Spacer()
            
            VStack {
                // display the selected image
                menuImage?
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                    .shadow(radius: 10)
                    .padding(.horizontal)
                
                // 按钮根据是否选择图片
                HStack {
                    PhotosPicker(menuImage != nil ? "更换图片" : "选择图片", selection: $menuItem, matching: .images)
                        .padding(.vertical)
                        .font(.title2)
                        .buttonStyle(BorderedProminentButtonStyle())
                        .onChange(of: menuItem) { oldValue, newValue in
                            Task {
                                if let loaded = try? await menuItem?.loadTransferable(type: Image.self) {
                                    withAnimation(.snappy) {
                                        menuImage = loaded
                                    }
                                } else {
                                    if newValue != nil {
                                        print("Select image failed")
                                    }
                                }
                                if let data = try? await menuItem?.loadTransferable(type: Data.self) {
                                    menuData = data
                                } else {
                                    if newValue != nil {
                                        print("Transfer image to data failed")
                                    }
                                    menuImage = nil
                                }
                            }
                        }
                    
                    if menuImage != nil {
                        Button {
                            uploadImage(imageData: menuData!)
                        } label: {
                            Text("上传菜单")
                        }
                        .font(.title2)
                        .padding(.vertical)
                        .buttonStyle(BorderedProminentButtonStyle())
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background(.orderListBackground)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        .shadow(radius: 10)
        .padding()
    }
    
    // 上传图片的函数
    private func uploadImage(imageData: Data) {        
        let url = URL(string: NSLocalizedString( sectionTitle == "主电视" ? "uploadMenuImage1" : "uploadMenuImage2", comment: "URL for uploading menu image"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 设置请求头
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 构建 multipart/form-data 请求体
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"menu.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // 使用 URLSession 的 uploadTask 上传数据
        let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("Upload error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Image uploaded successfully")
                withAnimation(.snappy) {
                    menuOnline = menuImage
                    menuImage = nil
                    menuItem = nil
                }
                
            } else {
                print("Upload failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            }
        }
        task.resume()
    }
}


#Preview {
    MenuImageView()
}
