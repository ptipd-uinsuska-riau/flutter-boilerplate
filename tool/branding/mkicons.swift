import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// Pemakaian: mkicons <sumber.png> <folder-keluar>   (lewat apply_icons.sh)
// Membuat semua ukuran ikon/splash dari SATU gambar sumber persegi
// (512 px atau lebih): logo BERWARNA di atas latar putih. Bagian yang tidak
// berwarna (putih, abu-abu, transparan) dianggap latar dan dibuang.

let args = CommandLine.arguments
guard args.count == 3 else { fatalError("pemakaian: mkicons <sumber> <keluar>") }
let srcURL = URL(fileURLWithPath: args[1])
let outDir = URL(fileURLWithPath: args[2])

guard let source = CGImageSourceCreateWithURL(srcURL as CFURL, nil),
      let srcImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
  fatalError("tak bisa membaca sumber")
}
let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!

func context(_ w: Int, _ h: Int) -> CGContext {
  let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8,
                      bytesPerRow: w * 4, space: sRGB,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.interpolationQuality = .high
  return ctx
}

// 1. Kotak pembatas logo (piksel yang berwarna dan tidak transparan).
let sw = srcImage.width, sh = srcImage.height
let probe = context(sw, sh)
probe.draw(srcImage, in: CGRect(x: 0, y: 0, width: sw, height: sh))
let px = probe.data!.bindMemory(to: UInt8.self, capacity: sw * sh * 4)
var minX = sw, minY = sh, maxX = -1, maxY = -1
for y in 0..<sh {
  for x in 0..<sw {
    let i = (y * sw + x) * 4
    let a = px[i + 3]
    // Tepi ubin putih (semi-transparan) bukan bagian dari logo.
    if a < 250 { continue }
    let r = Int(px[i]), g = Int(px[i + 1]), b = Int(px[i + 2])
    // Logo berwarna. Putih ubin dan garis tepi abu-abu pada berkas
    // sumber tidak berwarna -> dilewati.
    if max(r, g, b) - min(r, g, b) < 40 { continue }
    if x < minX { minX = x }; if x > maxX { maxX = x }
    if y < minY { minY = y }; if y > maxY { maxY = y }
  }
}
// Data bitmap CGContext beralas atas (baris 0 = atas); CGImage.cropping juga
// memakai koordinat beralas atas.
let glyphRect = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
guard let glyph = probe.makeImage()!.cropping(to: glyphRect) else { fatalError("crop") }
print("kotak logo: \(glyphRect) dari \(sw)x\(sh)")

enum Shape { case square, circle }

/// Kanvas `size` px; `fraction` = sisi terpanjang logo terhadap kanvas.
func render(_ size: Int, fraction: CGFloat, white: Bool, shape: Shape = .square) -> CGImage {
  let ctx = context(size, size)
  let full = CGRect(x: 0, y: 0, width: size, height: size)
  if shape == .circle { ctx.addEllipse(in: full); ctx.clip() }
  if white {
    ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
    ctx.fill(full)
  }
  let longer = CGFloat(max(glyph.width, glyph.height))
  let scale = CGFloat(size) * fraction / longer
  let w = CGFloat(glyph.width) * scale, h = CGFloat(glyph.height) * scale
  ctx.draw(glyph, in: CGRect(x: (CGFloat(size) - w) / 2, y: (CGFloat(size) - h) / 2, width: w, height: h))
  return ctx.makeImage()!
}

/// Ubin putih bersudut membulat + logo dengan proporsi seperti sumber, tanpa
/// garis tepi abu-abu yang ada di berkas sumber.
func tile(_ size: Int) -> CGImage {
  let ctx = context(size, size)
  let full = CGRect(x: 0, y: 0, width: size, height: size)
  let radius = CGFloat(size) * 0.18
  ctx.addPath(CGPath(roundedRect: full, cornerWidth: radius, cornerHeight: radius, transform: nil))
  ctx.clip()
  ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
  ctx.fill(full)
  // Posisi & skala logo sama dengan di sumber.
  let k = CGFloat(size) / CGFloat(sw)
  ctx.draw(glyph, in: CGRect(x: glyphRect.minX * k,
                             y: (CGFloat(sh) - glyphRect.maxY) * k,
                             width: glyphRect.width * k, height: glyphRect.height * k))
  return ctx.makeImage()!
}


func save(_ image: CGImage, _ relative: String) {
  let url = outDir.appendingPathComponent(relative)
  try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
  let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(dest, image, nil)
  guard CGImageDestinationFinalize(dest) else { fatalError("gagal menulis \(relative)") }
}

// ---- Android ----
let densities: [(String, CGFloat)] = [("mdpi", 1), ("hdpi", 1.5), ("xhdpi", 2), ("xxhdpi", 3), ("xxxhdpi", 4)]
for (name, k) in densities {
  let legacy = Int(48 * k)
  save(tile(legacy), "android/mipmap-\(name)/ic_launcher.png")
  save(render(legacy, fraction: 0.60, white: true, shape: .circle), "android/mipmap-\(name)/ic_launcher_round.png")
  // Latar depan ikon adaptif 108dp; logo di zona aman (±56% kanvas).
  save(render(Int(108 * k), fraction: 0.56, white: false), "android/mipmap-\(name)/ic_launcher_foreground.png")
  // Gambar layar pembuka 120dp di atas latar putih.
  save(render(Int(120 * k), fraction: 0.92, white: false), "android/drawable-\(name)/ic_launch_image.png")
}
save(tile(512), "android/ic_launcher-playstore.png")
save(tile(512), "pratinjau/ubin-512.png")
save(render(432, fraction: 0.56, white: true, shape: .circle), "pratinjau/adaptif-lingkaran-432.png")

// ---- iOS ----
for (suffix, size) in [("@1x", 200), ("@2x", 400), ("@3x", 600)] {
  save(render(size, fraction: 0.80, white: false), "ios/LaunchImage\(suffix).png")
}
// Lapisan logo utk AppIcon.icon: kotak putih penuh + logo.
save(render(1024, fraction: 0.62, white: true), "ios/Logo.png")
print("selesai")
