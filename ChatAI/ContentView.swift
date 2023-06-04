import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    
    init() {}
    private var client: OpenAISwift?
    
    func setup(){
        client = OpenAISwift(authToken: "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")
    }
    
    func send(text: String, completion: @escaping (String)-> Void) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices?.first?.text ?? ""
                completion(output)
            case .failure:
                break
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(models, id: \.self) { string in
                Text(string)
            }
            Spacer()
            HStack {
                TextField("type here...", text: $text)
                Button("Send") {
                    send()
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.setup()
        }
    }
    
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        models.append("me: \(text)")
        viewModel.send(text: text) { response in
            DispatchQueue.main.async {
                self.models.append("chatgpt: " + response)
                self.text = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
