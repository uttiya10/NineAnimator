

import Kingfisher
import SwiftUI

@available(iOS 14.0, *)
struct ImageSelector: View {
    @State var imagePreview: URL?
    @State var imagePreviewDownloadProgress: Double?
    
    @State var imageURLTextInput: String = ""
    @State var retrievalError: String? {
        didSet {
            // Reset image preview back to default when error is throw
            if retrievalError != nil {
                imagePreview = nil
            }
        }
    }
    
    @State var selectedImageFromLibrary: UIImage?
    // @State var selectedImageFromURL: URL?
    
    var uploadButtonColor: Color {
        imagePreview == nil ? .gray : Color.accentColor
    }
    
    var body: some View {
        VStack {
            Form {
                if imagePreview == nil {
                    // Display Placeholder Image
                    PlaceHolderImage()
                } else {
                    KFImage.url(imagePreview!)
                        .forceRefresh()
                        .fade(duration: 0.5)
                        .placeholder {
                            PlaceHolderImage()
                        }
                        .onProgress {
                            receivedSize, totalSize in
                            DispatchQueue.main.async {
                                let progress = Double(receivedSize) / Double(totalSize)
                                imagePreviewDownloadProgress = progress
                            }
                        }
                        .onSuccess { _ in imagePreviewDownloadProgress = nil }
                        .onFailure {
                            error in
                            imagePreviewDownloadProgress = nil
                            retrievalError = error.localizedDescription
                        }
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: 300, alignment: .center)
                }
                Section(header: Text("Enter Image URL"), footer: Text(retrievalError ?? "")) {
                    ImageURLInput(
                        imagePreview: $imagePreview,
                        previewDownloadProgress: $imagePreviewDownloadProgress,
                        error: $retrievalError
                    )
                }
                Section(header: Text("Upload Image")) {
                    Button("Select Image From Library") { }
                }
            }
            Button("UPLOAD") { print("Clicked UPLOAD") }
                .disabled(imagePreview == nil)
                .frame(maxWidth: .infinity, maxHeight: 44)
                .background(uploadButtonColor)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .padding(10)
        }
        .navigationTitle("Search From Image")
    }
}

@available(iOS 14.0, *)
struct PlaceHolderImage: View {
    var body: some View {
        Image("NineAnimator Lists Tip")
            .resizable()
            .scaledToFit()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: 300, alignment: .center)
    }
}

@available(iOS 14.0, *)
struct ImageURLInput: View {
    @Binding var imagePreview: URL?
    @Binding var previewDownloadProgress: Double?
    @Binding var error: String?
    @State var textInput: String = ""
    
    var body: some View {
        HStack {
            TextField("Enter URL", text: $textInput)
                .textFieldStyle(PlainTextFieldStyle())
            if previewDownloadProgress != nil {
                ProgressView(value: previewDownloadProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(maxWidth: 60)
            } else {
                Button("Load URL") { onLoadURLPressed() }
                    .foregroundColor(Color.accentColor)
                    .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    func onLoadURLPressed() {
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        if let inputtedURL = URL(string: textInput) {
            error = nil
            imagePreview = inputtedURL
        } else {
            error = "Invalid URL"
            imagePreview = nil
        }
    }
}

@available(iOS 14.0, *)
struct ImageSelector_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ImageSelector().preferredColorScheme(.light)
    }
}
