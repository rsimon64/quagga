layout_label <- function(i, header, info, tpl) {
  family <- tpl$fontfamily
  max_lines <- as.numeric(tpl$lines)

  rec <- info[i, ]
  top1 <- ifelse(header[1] == "today", as.character(Sys.Date()),
    header[1]
  )
  top2 <- ifelse(header[2] == "today", as.character(Sys.Date()),
    header[2]
  )
  top3 <- ifelse(header[3] == "today", as.character(Sys.Date()),
    header[3]
  )
  top4 <- rec$ID

  spacer <- ifelse(tpl$spacer == 1, "\n", "\n\n")

  block_order <-
    as.data.frame(cbind(
      pos = c(
        tpl$block_ID$position,
        tpl$block_QR$position,
        tpl$block_info$position,
        tpl$block_info_optional$position
      ),
      name = c("ID", "QR", "MI", "OI")
    ), stringsAsFactors = FALSE)

  # block_order = dplyr::arrange_(block_order, block_order$pos)$name
  block_order <- block_order[with(block_order, order(pos)), ]

  blc1 <- rec[c(2:5)]
  blc1n <- names(info[i, c(2:5)])
  mx <- ncol(rec)
  blc2 <- rec[c(6:mx)]
  blc2n <- names(info[i, c(6:mx)])

  txtq <- paste0(rec$ID)

  do_block_ID <- function() {
    empty_plot(max_lines)
    logo_path <- system.file(file.path("templates", tpl$block_ID$logo$path),
      package = "qr4genebanks"
    )

    # message(logo_path)

    if (is.null(logo_path)) {
      # message("Logo file not found.")
      logo_path <- system.file(
        file.path("templates", tpl$block_ID$logo$path),
        package = "qr4genebanks"
      )
    }

    if (file.exists(logo_path)) {
      # message("ok 1")
      img <- imager::load.image(logo_path)
      # message("ok 2 ")
      graphics::rasterImage(
        img,
        tpl$block_ID$logo$bl_x, tpl$block_ID$logo$bl_y,
        tpl$block_ID$logo$tr_x, tpl$block_ID$logo$tr_y
      )
      # message("ok 3")
    }


    graphics::text(
      x = tpl$block_ID$x_pos, y = tpl$block_ID$y_pos - 0,
      label = top1, family = family
    )
    graphics::text(
      x = tpl$block_ID$x_pos, y = tpl$block_ID$y_pos - 1,
      label = top2, family = family
    )
    graphics::text(
      x = tpl$block_ID$x_pos, y = tpl$block_ID$y_pos - 2,
      label = top3, family = family
    )
    graphics::text(
      x = tpl$block_ID$x_pos, y = tpl$block_ID$y_pos - 3,
      label = top4, family = family
    )
  }

  do_block_QR <- function() {
    # message(txtq)
    txtq <- txtq[1]
    raster::image(
      qrencoder::qrencode_raster(txtq),
      asp = 1, col = c("white", "black"),
      axes = FALSE, xlab = "", ylab = ""
    )
  }

  do_block_MI <- function() {
    empty_plot(max_lines)
    if (tpl$fieldnames) {
      graphics::legend(tpl$block_info$x_pos,
        tpl$block_info$y_pos + tpl$spacer / 2 - .15,
        legend = paste0(blc1n, spacer),
        bty = "n"
      )
      blc1 <- paste0(" ", blc1)
    }

    graphics::legend(tpl$block_info$x_pos,
      tpl$block_info$y_pos - 1.15 + .1 * tpl$spacer +
        tpl$spacer / 2,
      legend = paste0(" ", blc1, spacer), text.font = tpl$fontface_data,
      bty = "n"
    )
  }

  do_block_OI <- function() {
    empty_plot(max_lines)
    if (tpl$fieldnames) {
      graphics::legend(tpl$block_info_optional$x_pos,
        tpl$block_info_optional$y_pos +
          tpl$spacer / 2 - .15,
        legend = paste0(" ", blc2n, spacer),
        bty = "n"
      )
      blc2 <- paste0("", blc2)
    }

    graphics::legend(tpl$block_info$x_pos - 1,
      tpl$block_info$y_pos - 1.15 +
        .1 * tpl$spacer + tpl$spacer / 2,
      legend = paste0("", blc2, spacer), text.font = tpl$fontface_data,
      bty = "n"
    )
  }

  choose_block <- function(block_id) {
    switch(block_id,
      "ID" = do_block_ID(),
      "QR" = do_block_QR(),
      "MI" = do_block_MI(),
      "OI" = do_block_OI()
    )
  }

  lapply(block_order$name, choose_block)
}
