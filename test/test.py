# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


async def reset(dut):
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)

    dut.rst_n.value = 1

    for _ in range(5):
        await RisingEdge(dut.clk)


async def load_byte(dut, byte, is_key):
    dut.ui_in.value = byte

    # idle
    dut.uio_in.value = (is_key << 1) & 0xFE
    await RisingEdge(dut.clk)

    # pulse
    dut.uio_in.value = (is_key << 1) | 1
    await RisingEdge(dut.clk)

    # back to idle
    dut.uio_in.value = (is_key << 1) & 0xFE
    
    for _ in range(3):
        await RisingEdge(dut.clk)


@cocotb.test()
async def test_xor(dut):

    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    key = 0xA5
    data = 0x3C

    await load_byte(dut, data, is_key=0)
    await load_byte(dut, key, is_key=1)

  
    for _ in range(3):
        await RisingEdge(dut.clk)

  
    result = int(dut.uo_out.value)

    expected = key ^ data

    dut._log.info(f"result={result:#02x}, expected={expected:#02x}")

    assert result == expected, f"Mismatch: got {result:#02x}, expected {expected:#02x}"
