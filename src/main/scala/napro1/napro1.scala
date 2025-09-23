// SPDX-License-Identifier: Apache-2.0
package napro1

import chisel3._
import chisel3.util._
import chisel3.experimental._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}

/** IO bundle mirroring the VHDL entity `napro1`. */
class Napro1IO extends Bundle {
  // SPI + reset
  val ss      = Input(Bool())
  val sck     = Input(Clock())
  val mosi    = Input(Bool())
  val miso    = Output(Bool())
  val resetn  = Input(Bool())

  // Gesture clock & inputs
  val clk_gest = Input(Clock())
  val gest1_in = Input(UInt(16.W))
  val gest2_in = Input(UInt(16.W))

  // 10 MHz clock
  val clk_10m = Input(Clock())

  // Control/status to NB-TX
  val outselosc = Output(UInt(3.W))
  val pa_outsel = Output(UInt(21.W))

  // Request words
  val reqword_ppm  = Input(Bool())
  val reqword_dppm = Input(Bool())
  val reqword_out  = Output(Bool())

  // OOK domain outputs
  val clk_ook       = Output(Bool())
  val ena_ook_out   = Output(Bool())
  val data_ook      = Output(Bool())
  val data_ook_next = Output(Bool())
  val resetn_ook    = Output(Bool())

  // Transmit word
  val tx_word_out = Output(UInt(6.W))

  // PPM domain
  val clk_ppm    = Output(Bool())
  val resetn_ppm = Output(Bool())

  // DPPM domain
  val clk_dppm            = Output(Bool())
  val resetn_dppm         = Output(Bool())
  val dppm_cntrstval      = Output(Bool())
  val resetn_nbtx_ctrlgen = Output(Bool())

  // Clocks to coder
  val clk_1m_to_coder  = Output(Bool())
  val clk_10m_to_coder = Output(Bool())

  // Trims / tuning
  val trim_bits       = Output(UInt(64.W))
  val tunefreq_coarce = Output(UInt(3.W))
  val tunefreq_med    = Output(UInt(4.W))
  val tunefreq_fine_p = Output(UInt(6.W))
  val tunefreq_fine_n = Output(UInt(6.W))
}

/** External-module stub that binds exactly to VHDL entity `napro1`. */
class Napro1BB extends ExtModule {
  override def desiredName: String = "napro1"

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
  val outselosc = IO(Output(UInt(3.W)))
  val pa_outsel = IO(Output(UInt(21.W)))

  // Request words
  val reqword_ppm  = IO(Input(Bool()))
  val reqword_dppm = IO(Input(Bool()))
  val reqword_out  = IO(Output(Bool()))

  // OOK domain outputs
  val clk_ook       = IO(Output(Bool()))
  val ena_ook_out   = IO(Output(Bool()))
  val data_ook      = IO(Output(Bool()))
  val data_ook_next = IO(Output(Bool()))
  val resetn_ook    = IO(Output(Bool()))

  // Transmit word
  val tx_word_out = IO(Output(UInt(6.W)))

  // PPM domain
  val clk_ppm    = IO(Output(Bool()))
  val resetn_ppm = IO(Output(Bool()))

  // DPPM domain
  val clk_dppm            = IO(Output(Bool()))
  val resetn_dppm         = IO(Output(Bool()))
  val dppm_cntrstval      = IO(Output(Bool()))
  val resetn_nbtx_ctrlgen = IO(Output(Bool()))

  // Clocks to coder
  val clk_1m_to_coder  = IO(Output(Bool()))
  val clk_10m_to_coder = IO(Output(Bool()))

  // Trims / tuning
  val trim_bits       = IO(Output(UInt(64.W)))
  val tunefreq_coarce = IO(Output(UInt(3.W)))
  val tunefreq_med    = IO(Output(UInt(4.W)))
  val tunefreq_fine_p = IO(Output(UInt(6.W)))
  val tunefreq_fine_n = IO(Output(UInt(6.W)))
}

/** Chisel top that wires IO straight to the external VHDL block. */
class napro1 extends Module {
  val io = IO(new Napro1IO)
  val u  = Module(new Napro1BB)

  // SPI + reset
  u.ss     := io.ss
  u.sck    := io.sck
  u.mosi   := io.mosi
  io.miso  := u.miso
  u.resetn := io.resetn

  // Gesture
  u.clk_gest := io.clk_gest
  u.gest1_in := io.gest1_in
  u.gest2_in := io.gest2_in

  // 10 MHz clock
  u.clk_10m := io.clk_10m

  // Control/status
  io.outselosc := u.outselosc
  io.pa_outsel := u.pa_outsel

  // Requests
  u.reqword_ppm  := io.reqword_ppm
  u.reqword_dppm := io.reqword_dppm
  io.reqword_out := u.reqword_out

  // OOK
  io.clk_ook       := u.clk_ook
  io.ena_ook_out   := u.ena_ook_out
  io.data_ook      := u.data_ook
  io.data_ook_next := u.data_ook_next
  io.resetn_ook    := u.resetn_ook

  // TX word
  io.tx_word_out := u.tx_word_out

  // PPM
  io.clk_ppm    := u.clk_ppm
  io.resetn_ppm := u.resetn_ppm

  // DPPM
  io.clk_dppm            := u.clk_dppm
  io.resetn_dppm         := u.resetn_dppm
  io.dppm_cntrstval      := u.dppm_cntrstval
  io.resetn_nbtx_ctrlgen := u.resetn_nbtx_ctrlgen

  // Clocks to coder
  io.clk_1m_to_coder  := u.clk_1m_to_coder
  io.clk_10m_to_coder := u.clk_10m_to_coder

  // Trims / tuning
  io.trim_bits       := u.trim_bits
  io.tunefreq_coarce := u.tunefreq_coarce
  io.tunefreq_med    := u.tunefreq_med
  io.tunefreq_fine_p := u.tunefreq_fine_p
  io.tunefreq_fine_n := u.tunefreq_fine_n
}

/** Verilog generator entry point (emits the `napro1` Module). */
object napro1 extends App {
  (new ChiselStage).execute(
    args,
    Seq(ChiselGeneratorAnnotation(() => new napro1))
  )
}
