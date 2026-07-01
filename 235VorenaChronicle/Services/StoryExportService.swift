import UIKit

enum StoryExportService {
    static func exportText(theme: Theme, slides: [StorySlide]) -> String {
        var lines: [String] = []
        lines.append("\(theme.emoji) \(theme.title)")
        lines.append("")
        if !theme.description.isEmpty {
            lines.append(theme.description)
            lines.append("")
        }
        lines.append("Reflection: \(theme.reflectionPrompt)")
        if !theme.reflectionAnswer.isEmpty {
            lines.append(theme.reflectionAnswer)
        }
        lines.append("")
        lines.append("— Story Slides —")
        for (index, slide) in slides.enumerated() {
            lines.append("")
            lines.append("\(index + 1). [\(slide.moodTag.label)] \(slide.caption)")
            lines.append("   \(slide.date.formatted(date: .abbreviated, time: .omitted))")
        }
        return lines.joined(separator: "\n")
    }

    static func exportPDF(theme: Theme, slides: [StorySlide]) -> URL? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 40
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(theme.id.uuidString).pdf")

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        do {
            try renderer.writePDF(to: tempURL) { context in
                var y: CGFloat = margin

                func beginPageIfNeeded(requiredHeight: CGFloat) {
                    if y + requiredHeight > pageHeight - margin {
                        context.beginPage()
                        y = margin
                    }
                }

                context.beginPage()

                let titleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 22),
                    .foregroundColor: UIColor.white
                ]
                let bodyAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.lightGray
                ]
                let captionAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 13),
                    .foregroundColor: UIColor.white
                ]

                UIColor(red: 0, green: 0.22, blue: 0.45, alpha: 1).setFill()
                context.cgContext.fill(CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

                let title = "\(theme.emoji) \(theme.title)" as NSString
                title.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttrs)
                y += 32

                if !theme.description.isEmpty {
                    beginPageIfNeeded(requiredHeight: 40)
                    let desc = theme.description as NSString
                    desc.draw(in: CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: 60), withAttributes: bodyAttrs)
                    y += 50
                }

                beginPageIfNeeded(requiredHeight: 60)
                let prompt = "Reflection: \(theme.reflectionPrompt)" as NSString
                prompt.draw(in: CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: 40), withAttributes: bodyAttrs)
                y += 24

                if !theme.reflectionAnswer.isEmpty {
                    let answer = theme.reflectionAnswer as NSString
                    answer.draw(in: CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: 60), withAttributes: captionAttrs)
                    y += 50
                }

                y += 16

                for (index, slide) in slides.enumerated() {
                    let imageHeight: CGFloat = slide.hasPhoto ? 180 : 0
                    let blockHeight = imageHeight + 70
                    beginPageIfNeeded(requiredHeight: blockHeight)

                    if let fileName = slide.imageFileName,
                       let image = ImageStorageService.loadImage(fileName: fileName) {
                        let maxW = pageWidth - margin * 2
                        let aspect = image.size.width / max(image.size.height, 1)
                        let drawW = min(maxW, imageHeight * aspect)
                        let rect = CGRect(x: margin, y: y, width: drawW, height: imageHeight)
                        image.draw(in: rect)
                        y += imageHeight + 8
                    }

                    let header = "\(index + 1). [\(slide.moodTag.label)]" as NSString
                    header.draw(at: CGPoint(x: margin, y: y), withAttributes: captionAttrs)
                    y += 18

                    let caption = slide.caption as NSString
                    caption.draw(in: CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: 50), withAttributes: bodyAttrs)
                    y += 40
                }
            }
            return tempURL
        } catch {
            return nil
        }
    }
}
