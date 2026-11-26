import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// Pemakaian: placeholder_logo <keluar.png>
// Menggambar logo PENGGANTI SEMENTARA 1024 px (empat kotak teal di atas
// putih) yang dipakai kerangka ini sampai aplikasi punya logo sendiri.

let args = CommandLine.arguments
guard args.count == 2 else { fatalError("pemakaian: placeholder_logo <keluar.png>") }
let size = 1024
let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                    bytesPerRow: size * 4,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))

// AppColors.primary (#02929A) dan AppColors.primaryLight (#5FB8BE).
let primary = CGColor(srgbRed: 0x02 / 255.0, green: 0x92 / 255.0, blue: 0x9A / 255.0, alpha: 1)
let light = CGColor(srgbRed: 0x5F / 255.0, green: 0xB8 / 255.0, blue: 0xBE / 255.0, alpha: 1)
let cell: CGFloat = 250, gap: CGFloat = 60
let origin = (CGFloat(size) - (cell * 2 + gap)) / 2
for row in 0..<2 {
  for col in 0..<2 {
    let rect = CGRect(x: origin + CGFloat(col) * (cell + gap),
                      y: origin + CGFloat(row) * (cell + gap),
                      width: cell, height: cell)
    ctx.addPath(CGPath(roundedRect: rect, cornerWidth: 56, cornerHeight: 56, transform: nil))
    // Kotak kanan-atas lebih muda supaya logo tidak simetris polos.
    ctx.setFillColor(row == 1 && col == 1 ? light : primary)
    ctx.fillPath()
  }
}
let url = URL(fileURLWithPath: args[1])
let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
guard CGImageDestinationFinalize(dest) else { fatalError("gagal menulis") }
print("selesai: \(url.path)")
