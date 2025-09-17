// SPDX-License-Identifier: Apache-2.0

// Initially written by Omar Numan (omar.numan@aalto.fi), 2025-08-05
package coderP

import chisel3._
import chisel3.util._
import chisel3.experimental._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}

/** IO bundle matching VHDL entity coderP */
class CoderPIO extends Bundle {
  // clocks & reset
  val clk         = Input(Clock())
  val clk_10m     = Input(Clock())
  val resetn      = Input(Bool())

  // selects
  val outsel0     = Input(UInt(3.W))
  val outsel1     = Input(UInt(3.W))
  val outsel2     = Input(UInt(3.W))
  val outsel3     = Input(UInt(3.W))
  val outsel4     = Input(UInt(3.W))
  val outsel5     = Input(UInt(3.W))
  val outsel6     = Input(UInt(3.W))
  val outselosc   = Input(UInt(3.W))

  // DPPM
  val word_in     = Input(UInt(6.W))
  val cntrstval   = Input(Bool())
  val reqword     = Output(Bool())
  val resetn_nbtx_ctrlgen = Input(Bool())

  // OOK
  val ena_ook     = Input(Bool())
  val thisbit_in  = Input(Bool())
  val nextbit_in  = Input(Bool())

  // outputs
  val pulse_trig  = Output(Bool())
  val tx_ena      = Output(Bool())
  val osc_ena     = Output(Bool())
  val pa_ena_out0 = Output(Bool())
  val pa_ena_out1 = Output(Bool())
  val pa_ena_out2 = Output(Bool())
  val pa_ena_out3 = Output(Bool())
  val pa_ena_out4 = Output(Bool())
  val pa_ena_out5 = Output(Bool())
  val pa_ena_out6 = Output(Bool())
}

/** External module stub that binds to VHDL entity `coderP` */
class CoderPBB extends ExtModule {
  override def desiredName: String = "coderP" // must match VHDL entity name
  val clk         = IO(Input(Clock()))
  val clk_10m     = IO(Input(Clock()))
  val resetn      = IO(Input(Bool()))

  val outsel0     = IO(Input(UInt(3.W)))
  val outsel1     = IO(Input(UInt(3.W)))
  val outsel2     = IO(Input(UInt(3.W)))
  val outsel3     = IO(Input(UInt(3.W)))
  val outsel4     = IO(Input(UInt(3.W)))
  val outsel5     = IO(Input(UInt(3.W)))
  val outsel6     = IO(Input(UInt(3.W)))
  val outselosc   = IO(Input(UInt(3.W)))

  val word_in     = IO(Input(UInt(6.W)))
  val cntrstval   = IO(Input(Bool()))
  val reqword     = IO(Output(Bool()))
  val resetn_nbtx_ctrlgen = IO(Input(Bool()))

  val ena_ook     = IO(Input(Bool()))
  val thisbit_in  = IO(Input(Bool()))
  val nextbit_in  = IO(Input(Bool()))

  val pulse_trig  = IO(Output(Bool()))
  val tx_ena      = IO(Output(Bool()))
  val osc_ena     = IO(Output(Bool()))
  val pa_ena_out0 = IO(Output(Bool()))
  val pa_ena_out1 = IO(Output(Bool()))
  val pa_ena_out2 = IO(Output(Bool()))
  val pa_ena_out3 = IO(Output(Bool()))
  val pa_ena_out4 = IO(Output(Bool()))
  val pa_ena_out5 = IO(Output(Bool()))
  val pa_ena_out6 = IO(Output(Bool()))
}

/** Chisel top that simply wires IO to the external VHDL block */
class coderP extends Module {
  val io = IO(new CoderPIO)

  val u = Module(new CoderPBB)

  // Clocks & reset (note: VHDL reset is active-low data port, *not* Chisel reset)
  u.clk     := io.clk
  u.clk_10m := io.clk_10m
  u.resetn  := io.resetn

  // Selects
  u.outsel0   := io.outsel0
  u.outsel1   := io.outsel1
  u.outsel2   := io.outsel2
  u.outsel3   := io.outsel3
  u.outsel4   := io.outsel4
  u.outsel5   := io.outsel5
  u.outsel6   := io.outsel6
  u.outselosc := io.outselosc

  // DPPM
  u.word_in   := io.word_in
  u.cntrstval := io.cntrstval
  io.reqword  := u.reqword
  u.resetn_nbtx_ctrlgen := io.resetn_nbtx_ctrlgen

  // OOK
  u.ena_ook    := io.ena_ook
  u.thisbit_in := io.thisbit_in
  u.nextbit_in := io.nextbit_in

  // Outputs
  io.pulse_trig  := u.pulse_trig
  io.tx_ena      := u.tx_ena
  io.osc_ena     := u.osc_ena
  io.pa_ena_out0 := u.pa_ena_out0
  io.pa_ena_out1 := u.pa_ena_out1
  io.pa_ena_out2 := u.pa_ena_out2
  io.pa_ena_out3 := u.pa_ena_out3
  io.pa_ena_out4 := u.pa_ena_out4
  io.pa_ena_out5 := u.pa_ena_out5
  io.pa_ena_out6 := u.pa_ena_out6
}

import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}

object coderP extends App {
  (new ChiselStage).execute(
    args,
    Seq(ChiselGeneratorAnnotation(() => new coderP))
  )
}
