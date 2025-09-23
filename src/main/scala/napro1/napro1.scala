// SPDX-License-Identifier: Apache-2.0
package napro1

import chisel3._
import chisel3.experimental._
import chisel3.util._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}

/** Blackbox stub that matches VHDL entity `napro1`. */
class napro1 extends ExtModule {
  // SPI + reset
  val ss      = IO(Input(Bool()))
  val sck     = IO(Input(Clock()))
  val mosi    = IO(Input(Bool()))
  val miso    = IO(Output(Bool()))
  val resetn  = IO(Input(Bool()))

  // Gesture clock & inputs
  val clk_gest = IO(Input(Clock()))
  val gest1_in = IO(Input(UInt(16.W)))
  val gest2_in = IO(Input(UInt(16.W)))

  // 10 MHz clock
  val clk_10m = IO(Input(Clock()))

  // Control/status to NB-TX
  val outselosc      = IO(Output(UInt(3.W)))
  val pa_outsel      = IO(Output(UInt(21.W)))

  // Request words
  val reqword_ppm    = IO(Input(Bool()))
  val reqword_dppm   = IO(Input(Bool()))
  val reqword_out    = IO(Output(Bool()))

  // OOK domain outputs
  val clk_ook        = IO(Output(Bool()))
  val ena_ook_out    = IO(Output(Bool()))
  val data_ook       = IO(Output(Bool()))
  val data_ook_next  = IO(Output(Bool()))
  val resetn_ook     = IO(Output(Bool()))

  // Transmit word
  val tx_word_out    = IO(Output(UInt(6.W)))

  // PPM domain
  val clk_ppm        = IO(Output(Bool()))
  val resetn_ppm     = IO(Output(Bool()))

  // DPPM domain
  val clk_dppm           = IO(Output(Bool()))
  val resetn_dppm        = IO(Output(Bool()))
  val dppm_cntrstval     = IO(Output(Bool()))
  val resetn_nbtx_ctrlgen= IO(Output(Bool()))

  // Clocks to coder
  val clk_1m_to_coder    = IO(Output(Bool()))
  val clk_10m_to_coder   = IO(Output(Bool()))

  // Trims / tuning
  val trim_bits       = IO(Output(UInt(64.W)))
  val tunefreq_coarce = IO(Output(UInt(3.W)))
  val tunefreq_med    = IO(Output(UInt(4.W)))
  val tunefreq_fine_p = IO(Output(UInt(6.W)))
  val tunefreq_fine_n = IO(Output(UInt(6.W)))
}

import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}

object napro1 extends App {
  (new ChiselStage).execute(
    args,
    Seq(ChiselGeneratorAnnotation(() => new napro1))
  )
}

