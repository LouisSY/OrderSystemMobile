//
//  SendRequest.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 23/08/2024.
//

import Foundation

/// 发送 HTTP POST 请求到指定的 URL，并处理 JSON 响应
///
/// 该函数创建一个 HTTP POST 请求，将指定类型的 `Codable` 对象编码为 JSON 数据，并将其作为请求体发送到指定的 URL。函数在完成请求后，解析响应数据并通过回调处理结果。
///
/// - Parameters:
///   - urlString: 目标 URL 的字符串表示。必须是有效的 URL 地址。
///   - requestBody: 要发送的请求体数据，符合 `Codable` 协议的泛型对象。将被编码为 JSON。
///   - completion: 请求完成后的回调闭包。接收一个 `Result` 类型的参数：成功时包含响应的消息字符串，失败时包含错误信息。
///
/// - Returns: 无返回值。请求的结果通过 `completion` 闭包传递。
///
/// - Note:
///   - 如果 `urlString` 无效，或者请求体无法编码为 JSON，或者请求失败，将会调用 `completion` 闭包，并传递相应的错误信息。
///   - 如果响应状态码不在 200 到 299 的范围内，将会调用 `completion` 闭包，并传递状态码相关的错误信息。
///   - 如果响应数据格式不符合预期，或者无法解析响应数据，也会调用 `completion` 闭包，并传递错误信息。
func sendRequest<T: Codable>(urlString: String, requestBody: T, completion: @escaping (Result<String, Error>) -> Void) {
    // 创建 URL 对象
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    // 配置 URLRequest 对象
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // 编码请求体为 JSON
    do {
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
    } catch {
        completion(.failure(error))
        return
    }

    // 发送网络请求
    URLSession.shared.dataTask(with: request) { data, response, error in
        // 处理请求错误
        if let error = error {
            completion(.failure(error))
            return
        }

        // 验证 HTTP 响应状态码
        guard let httpResponse = response as? HTTPURLResponse else {
            let errorMessage = "Invalid response"
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            return
        }

        // 如果状态码不在 200-299 之间，解析错误响应
        if !(200...299).contains(httpResponse.statusCode) {
            if let data = data {
                do {
                    if let errorResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = errorResponse["message"] as? String {
                        // 解析并传递自定义错误消息
                        completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    } else {
                        let errorMessage = "Unexpected response format"
                        completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                let errorMessage = "No data received"
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
            return
        }

        // 处理成功响应数据
        guard let data = data else {
            let errorMessage = "No data received"
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            return
        }

        // 解析 JSON 响应数据
        do {
            let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let message = responseDict?["message"] as? String {
                completion(.success(message))
            } else {
                let errorMessage = "Invalid response format"
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
