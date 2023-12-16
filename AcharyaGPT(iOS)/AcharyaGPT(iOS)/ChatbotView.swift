//
//  ContentView.swift
//  AcharyaGPT
//
//  Created by Abhilekh Borah on 13/10/23.
//

import SwiftUI
import Alamofire
struct ChatbotView: View {
    @State var hasScrolled = false
    @State var sendClicked: Bool = false
    @State var query: String = ""
    @StateObject private var chatViewModel = ChatViewModel()
    @FocusState private var isFocused: Bool
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false){
                    LazyVStack(spacing: 16){
                        scrollDetection
                        
                        Image("acharyaLogoLarge")
                            .frame(width: 60.44444, height: 50.99986)
                            .padding()
                        
                        IntroductionView()
                        
                        ForEach(0..<4) { spacer in
                            Spacer()
                        }
                        
                        ForEach(chatViewModel.chatMessages){ message in
                            messageView(message)
                        }
                        
                        Color.clear.frame(height: 100)
                            .id("bottom")
                        
                    }
                }
                .onReceive(chatViewModel.$chatMessages.throttle(for: 0.5, scheduler: RunLoop.main, latest: true), perform: { chatMessages in
                    guard !chatMessages.isEmpty else { return }
                    withAnimation {
                        proxy.scrollTo("bottom")
                    }
                })
                .coordinateSpace(name: "scroll")
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 70)
                })
                .overlay(NavigationView(hasScrolled: $hasScrolled))
            }
            queryTypeView
                .frame(maxWidth: .infinity)
            
        }
        .background(Color(red: 0.05, green: 0.06, blue: 0.06))
    }
    func messageView(_ message: ChatMessage) -> some View{
        HStack {
         
            if !message.text.isEmpty {
                VStack(alignment: .leading){
                    Image(message.owner == .user ? "senderProfile" : "acharyaLogo").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                        .background(
                            Image("ellipse").frame(width: 24, height: 24)
                                .padding(.leading, 2)
                                .padding(.top, 2)
                        )
                        .frame(width: 12, alignment: .topLeading)
                        .padding(.trailing)
                        .padding(.bottom, 8)
                        .padding(.leading, 5)
                        .padding(.top, 5)
                    
                    Text(message.text)
                        .textSelection(.enabled)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 16))
                        .kerning(0.32)
                        .foregroundColor(Color(red: 0.92, green: 0.92, blue: 0.92))
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(
                  LinearGradient(
                    stops: [
                      Gradient.Stop(color: .white.opacity(0.08), location: 0.00),
                      Gradient.Stop(color: .white.opacity(0.08), location: 0.00),
                      Gradient.Stop(color: .white.opacity(0.18), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0, y: 0),
                    endPoint: UnitPoint(x: 1, y: 1)
                  )
                )
                .cornerRadius(12)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.6)
                    .stroke(.linearGradient(colors: [.white.opacity(0.2), .white.opacity(0.4),.white.opacity(0.3), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
            }
     
        }
        .padding(.horizontal)
    }
    func sendMessage() {
        Task {
            do {
                try await chatViewModel.sendMessage()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    var scrollDetection: some View {
        
        GeometryReader{ proxy in
            Color.clear.preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
        }
        .frame(height: 0)
        .onPreferenceChange(ScrollPreferenceKey.self, perform: { value in
            withAnimation(.easeInOut(duration: 0.4)){
                if value < 0{
                    hasScrolled = true
                } else{
                    hasScrolled = false
                }
            }
        })
    }
    
    var queryTypeView: some View {
        GeometryReader { proxy in
            let hasHomeIndicator = proxy.safeAreaInsets.bottom > 20
            queryBody
                .padding(.top, 12)
                .padding(.bottom, 32)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: hasHomeIndicator ? 8 : 0, style: .continuous))
                .strokeStyle(cornerRadius: hasHomeIndicator ? 8 : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
//                .focused($isFocused)
//                .lineLimit(1...12)
//                .toolbar {
//                    ToolbarItem(placement: .keyboard) {
//                        HStack {
//                            Spacer()
//                            Button("Done") {
//                                isFocused = false
//                            }
//                        }
//                    }
//                }
                .ignoresSafeArea()
                
        }
    }
    
    var queryBody: some View {
        VStack(alignment: .leading, spacing: 16){
            HStack(alignment: .top){
                TextField("What's your query?", text: $chatViewModel.message, axis: .vertical)
                    .kerning(0.32)
                    .foregroundColor(Color(red: 0.68, green: 0.68, blue: 0.68))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(16)
                    .frame(width: 292, alignment: .center)
                    .background(Color(red: 0.05, green: 0.05, blue: 0.06).opacity(0.4))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .inset(by: 0.4)
                            .stroke(.linearGradient(colors: [.white.opacity(0.52), .white.opacity(0.4), .white.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.8)
                    )
                
                Spacer()
                if chatViewModel.isWaitingForResponse {
                    ProgressView().padding()
                }
                else{
                    Image("sendButton")
                        .frame(width: 24, height: 24)
                        .padding(0)
                        .frame(width: 52, height: 52, alignment: .center)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: .white.opacity(0.16), location: 0.00),
                                    Gradient.Stop(color: .white.opacity(0.1), location: 0.52),
                                    Gradient.Stop(color: .white.opacity(0.1), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0, y: 0),
                                endPoint: UnitPoint(x: 1, y: 1)
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color(red: 0.12, green: 0.12, blue: 0.12).opacity(0.24), radius: 2, x: 2, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .inset(by: 0.5)
                                .stroke(.white.opacity(0.4), lineWidth: 1)
                        )
                        .scaleEffect(sendClicked ? 0.8 : 1)
                        .onTapGesture {
                            sendMessage()
                            print("Query Sent")
                            withAnimation(.spring(duration: 0.2)){
                                sendClicked.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(duration: 0.2)) {
                                    sendClicked.toggle()
                                }
                            }
                            
                        }
                }
                
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 0)
            .frame(width: 390, alignment: .top)
                
        }
    }
    
}

#Preview {
    ChatbotView().preferredColorScheme(.dark).background(Color(red: 0.05, green: 0.06, blue: 0.06))
}

