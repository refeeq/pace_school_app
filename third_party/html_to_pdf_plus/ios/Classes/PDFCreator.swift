import PDFKit
import UIKit

enum PDFCreatorError: LocalizedError {
    case documentsDirectoryUnavailable
    case writeFailed(String)

    var errorDescription: String? {
        switch self {
        case .documentsDirectoryUnavailable:
            return "Could not access the documents directory."
        case .writeFailed(let message):
            return message
        }
    }
}

class PDFCreator {

    /**
     Creates a PDF using the given print formatter and saves it to the user's document directory.
     - returns: The generated PDF path.
     */
    class func create(
        printFormatter: UIPrintFormatter,
        width: Double,
        height: Double,
        fitToSinglePage: Bool = false,
        singlePageHTML: String? = nil
    ) throws -> URL {
        if fitToSinglePage, let html = singlePageHTML, !html.isEmpty {
            return try createSingleSheet(
                html: html,
                pageWidth: CGFloat(width),
                targetHeight: CGFloat(height)
            )
        }

        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)

        let page = CGRect(x: 0, y: 0, width: width, height: height)
        let printable = page.insetBy(dx: 0, dy: 0)

        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(printable, forKey: "printableRect")

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)

        let pageCount = renderer.numberOfPages
        if pageCount > 0 {
            for i in 0..<pageCount {
                UIGraphicsBeginPDFPageWithInfo(printable, nil)
                renderer.drawPage(at: i, in: CGRect(x: 0, y: 0, width: page.width, height: page.height))
            }
        } else {
            UIGraphicsBeginPDFPageWithInfo(printable, nil)
        }

        UIGraphicsEndPDFContext()

        let url = try createdFileURL()
        do {
            try pdfData.write(to: url, options: .atomic)
        } catch {
            throw PDFCreatorError.writeFailed(error.localizedDescription)
        }
        return url
    }

    /// Lays the receipt out at the same width as a normal page, then writes one
    /// PDF page tall enough for the whole document so it is not split in two.
    private class func createSingleSheet(
        html: String,
        pageWidth: CGFloat,
        targetHeight: CGFloat
    ) throws -> URL {
        let contentHeight = measuredContentHeight(html: html, width: pageWidth)
        guard contentHeight > 1 else {
            throw PDFCreatorError.writeFailed("Could not measure the receipt.")
        }

        // Keep a normal A4 page when the invoice fits. Only grow the page when
        // the footer would otherwise be pushed onto a second sheet.
        let fittedHeight = contentHeight + 16
        let pageHeight = fittedHeight <= targetHeight ? targetHeight : fittedHeight
        let page = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let formatter = UIMarkupTextPrintFormatter(markupText: html)
        formatter.perPageContentInsets = .zero
        formatter.maximumContentWidth = pageWidth

        let renderer = UIPrintPageRenderer()
        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(page, forKey: "printableRect")
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, page, nil)
        UIGraphicsBeginPDFPageWithInfo(page, nil)
        if renderer.numberOfPages > 0 {
            renderer.drawPage(at: 0, in: page)
        }
        UIGraphicsEndPDFContext()

        let url = try createdFileURL()
        do {
            try pdfData.write(to: url, options: .atomic)
        } catch {
            throw PDFCreatorError.writeFailed(error.localizedDescription)
        }
        return url
    }

    /// Smallest page height that holds the document on one sheet.
    private class func measuredContentHeight(html: String, width: CGFloat) -> CGFloat {
        var low: CGFloat = 40
        var high: CGFloat = 6000
        var best = high

        if pageCount(html: html, width: width, height: high) > 1 {
            return high
        }

        for _ in 0..<14 {
            let mid = (low + high) / 2
            if pageCount(html: html, width: width, height: mid) <= 1 {
                best = mid
                high = mid
            } else {
                low = mid
            }
        }
        return ceil(best)
    }

    private class func pageCount(html: String, width: CGFloat, height: CGFloat) -> Int {
        let formatter = UIMarkupTextPrintFormatter(markupText: html)
        formatter.perPageContentInsets = .zero
        formatter.maximumContentWidth = width

        let renderer = UIPrintPageRenderer()
        let page = CGRect(x: 0, y: 0, width: width, height: height)
        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(page, forKey: "printableRect")
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        return renderer.numberOfPages
    }

    class func writePDFData(_ data: Data) throws -> URL {
        let url = try createdFileURL()
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw PDFCreatorError.writeFailed(error.localizedDescription)
        }
        return url
    }

    /// Joins a paginated receipt into one page and drops the blank tail under the footer.
    class func singlePageData(from data: Data) -> Data {
        guard let document = PDFDocument(data: data), document.pageCount > 1 else {
            return data
        }

        var width: CGFloat = 0
        var totalHeight: CGFloat = 0
        var slices: [(PDFPage, CGFloat)] = []
        for index in 0..<document.pageCount {
            guard let page = document.page(at: index) else { continue }
            let bounds = page.bounds(for: .mediaBox)
            let isLast = index == document.pageCount - 1
            let used = isLast ? usedHeightFromTop(of: page) : bounds.height
            width = max(width, bounds.width)
            totalHeight += used
            slices.append((page, used))
        }
        guard width > 1, totalHeight > 1 else { return data }

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: width, height: totalHeight)
        )
        return renderer.pdfData { context in
            context.beginPage()
            var yFromTop: CGFloat = 0
            for (page, used) in slices {
                let bounds = page.bounds(for: .mediaBox)
                context.cgContext.saveGState()
                // UIGraphics PDF context grows upward. Flip each slice so page 1
                // stays above the footer, and keep only the top of the last page.
                context.cgContext.translateBy(x: 0, y: yFromTop + used)
                context.cgContext.scaleBy(x: 1, y: -1)
                context.cgContext.clip(to: CGRect(x: 0, y: 0, width: bounds.width, height: used))
                context.cgContext.translateBy(x: 0, y: used - bounds.height)
                page.draw(with: .mediaBox, to: context.cgContext)
                context.cgContext.restoreGState()
                yFromTop += used
            }
        }
    }

    private class func usedHeightFromTop(of page: PDFPage) -> CGFloat {
        let bounds = page.bounds(for: .mediaBox)
        let sample: CGFloat = 0.25
        let pixelWidth = max(Int(bounds.width * sample), 1)
        let pixelHeight = max(Int(bounds.height * sample), 1)
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: pixelWidth, height: pixelHeight)
        )
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
            context.cgContext.translateBy(x: 0, y: CGFloat(pixelHeight))
            context.cgContext.scaleBy(x: sample, y: -sample)
            page.draw(with: .mediaBox, to: context.cgContext)
        }
        guard let cgImage = image.cgImage,
              let provider = cgImage.dataProvider,
              let raw = provider.data,
              let pixels = CFDataGetBytePtr(raw) else {
            return bounds.height
        }

        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = max(cgImage.bitsPerPixel / 8, 1)
        var lastInkRow = 0
        for y in 0..<cgImage.height {
            let row = pixels + y * bytesPerRow
            var hasInk = false
            for x in stride(from: 0, to: cgImage.width, by: 2) {
                let pixel = row + x * bytesPerPixel
                let r = pixel[0]
                let g = bytesPerPixel > 1 ? pixel[1] : r
                let b = bytesPerPixel > 2 ? pixel[2] : r
                if r < 248 || g < 248 || b < 248 {
                    hasInk = true
                    break
                }
            }
            if hasInk {
                lastInkRow = y
            }
        }
        if lastInkRow == 0 {
            return bounds.height
        }
        let used = CGFloat(lastInkRow + 1) / CGFloat(cgImage.height) * bounds.height + 18
        return min(bounds.height, max(used, 1))
    }

    /**
     Creates temporary PDF document URL
     */
    private class func createdFileURL() throws -> URL {
        let directory: URL
        do {
            directory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
        } catch {
            throw PDFCreatorError.documentsDirectoryUnavailable
        }
        return directory.appendingPathComponent("generatedPdfFile").appendingPathExtension("pdf")
    }
}
