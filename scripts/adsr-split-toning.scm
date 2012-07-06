; Split-toning effect
;
; Copyright (C) 2011 AdSR
;
; Version 1.2
; Original author: AdSR
; (C) 2011
;
; Tags: photo, split-toning
;
; See: http://gimp-tutorials.net/GIMP-split-toning-tutorial

(define (adsr-split-toning image layer highlights hi-opacity shadows
                           desaturate-orig)
  (gimp-image-undo-group-start image)
 
  (define (add-masked-layer image layer name tint invert-mask)
    (let* ((tint-layer (car (gimp-layer-new image
                                            (car (gimp-image-width image))
                                            (car (gimp-image-height image))
                                            (car (gimp-drawable-type layer))
                                            "Tint" 100 OVERLAY-MODE))))

      (gimp-drawable-set-name layer name)
      (gimp-image-add-layer image layer -1)
      (gimp-desaturate-full layer DESATURATE-LIGHTNESS)

      (gimp-image-set-active-layer image layer)
      (gimp-image-add-layer image tint-layer -1)

      (gimp-context-set-foreground tint)
      (gimp-drawable-fill tint-layer FOREGROUND-FILL)
      (gimp-image-set-active-layer image tint-layer)
      (set! layer
        (car (gimp-image-merge-down image tint-layer CLIP-TO-IMAGE)))

      (let* ((mask (car (gimp-layer-create-mask layer ADD-COPY-MASK))))
        (gimp-layer-add-mask layer mask)
        (if (= invert-mask TRUE)
          (gimp-invert mask)))

      layer))

  (if (<> (car (gimp-image-base-type image)) RGB)
    (gimp-image-convert-rgb image))

  (if (= desaturate-orig TRUE)
    (gimp-desaturate-full layer DESATURATE-LIGHTNESS))

  (let* ((hi-layer (car (gimp-layer-copy layer TRUE)))
         (lo-layer (car (gimp-layer-copy layer TRUE)))
         (original-fg (car (gimp-context-get-foreground))))

    (add-masked-layer image lo-layer "Shadows" shadows TRUE)
    (gimp-layer-set-opacity
      (add-masked-layer image hi-layer "Highlights" highlights FALSE)
      hi-opacity)
    
    (gimp-context-set-foreground original-fg))

  (gimp-image-undo-group-end image)
  (gimp-displays-flush))

(script-fu-register "adsr-split-toning"
                    _"Split-Toning..."
                    _"Rore's split-toning effect."
                    "AdSR (adsr at poczta onet pl)"
                    "Copyright (C) 2011 AdSR"
                    "2011-07-31"
                    "*"
                    SF-IMAGE      "Input image"    0
                    SF-DRAWABLE   "Input drawable" 0
                    SF-COLOR      _"Highlights" '(255 198 00)
                    SF-ADJUSTMENT _"Highlights opacity" (list 75 0 100 1 5 0
                                                              SF-SLIDER)
                    SF-COLOR      _"Shadows" '(43 198 255)
                    SF-TOGGLE     _"Desaturate original" FALSE)

(script-fu-menu-register "adsr-split-toning" _"<Image>/Filters/Artistic")
