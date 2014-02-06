; High-pass sharpening
;
; Copyright (C) 2014 AdSR
;
; Version 1.0
; Original author: AdSR
; (C) 2014
;
; Tags: photo, sharpening, high-pass, highpass

(define (adsr-highpass-sharpen image layer radius)
  (gimp-image-undo-group-start image)
 
  (let ((parent (car (gimp-item-get-parent layer)))
        (sharpen-layer (car (gimp-layer-copy layer FALSE))))

    (gimp-item-set-name sharpen-layer "High-pass sharpen")
    (gimp-image-insert-layer image sharpen-layer parent -1)
    (gimp-desaturate-full sharpen-layer DESATURATE-LIGHTNESS)

    (let ((blur-layer (car (gimp-layer-copy sharpen-layer FALSE))))

      (gimp-image-insert-layer image blur-layer parent -1)
      (plug-in-gauss-iir2 RUN-NONINTERACTIVE image blur-layer radius radius)
      (gimp-layer-set-mode blur-layer GRAIN-EXTRACT-MODE)
      (set! sharpen-layer
        (car (gimp-image-merge-down image blur-layer CLIP-TO-IMAGE))))

    (gimp-layer-set-mode sharpen-layer GRAIN-MERGE-MODE))

  (gimp-image-undo-group-end image)
  (gimp-displays-flush))

(script-fu-register "adsr-highpass-sharpen"
                    _"High-Pass Sharpen..."
                    _"Creates a sharpening overlay layer using high-pass sharpening technique."
                    "AdSR (adsr at poczta onet pl)"
                    "Copyright (C) 2014 AdSR"
                    "2014-02-06"
                    "*"
                    SF-IMAGE      "Input image"    0
                    SF-DRAWABLE   "Input drawable" 0
                    SF-ADJUSTMENT _"Radius" (list 3 0 100 1 5 1 SF-SPINNER))

(script-fu-menu-register "adsr-highpass-sharpen" _"<Image>/Filters/Enhance")
