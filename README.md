# Forked Excel Parsing Benchmarks

A fork of @shkm's project to test improvements to [simple_xlsx_reader](https://github.com/woahdae/simple_xlsx_reader).

Benchmarking the speed of reading xlsx files with various Ruby libraries.

## Usage

1. `bundle`
2. `./benchmark.sh`.
3. `./big-benchmark.sh`.

The project comes with three sample files originally found [here](https://eforexcel.com/wp/downloads-18-sample-csv-files-data-sets-for-testing-sales/):

* `10k_sales_records_non_unique.xlsx` simplest to parse, having mostly non-unique strings, which is what I could find in stock sample data. Excel's shared strings usage is a great optimization for this kind of file.
* `10k_sales_records.xlsx` whose first four string columns have unique values, which is IMO more representative of many real-world data files and makes the shared strings portion of the xlsx archive significant.
* `300k_sales_records.xlsx` also using unique/representative strings but much larger.

Test them via:

`WORKBOOK=10k_sales_records_non_unique.xlsx ./benchmark.sh`

## Results

Run on a 2021 Macbook Pro M1.

The TL;DR resultset is this - `./benchmark.sh` run against
`10k_sales_records.xlsx`, which best shows the difference between
simple_xlsx_reader and others:

| Gem                | Parses/second | RSS Increase | Allocated Mem | Retained Mem | Allocated Objects | Retained Objects |
|--------------------|---------------|--------------|---------------|--------------|-------------------|------------------|
| simple_xlsx_reader | 1.13          | 36.94mb      | 614.51mb      | 1.13kb       | 8796275           | 3                |
| roo                | 0.75          | 74.0mb       | 164.47mb      | 2.18kb       | 2128396           | 4                |
| creek              | 0.65          | 107.55mb     | 581.38mb      | 3.3kb        | 7240760           | 16               |
| xsv                | 0.61          | 75.66mb      | 2127.42mb     | 3.66kb       | 5922563           | 10               |
| rubyxl             | 0.27          | 373.52mb     | 716.7mb       | 2.18kb       | 10612577          | 4                |

It's interesting to note what happens when you have a file that doesn't use much shared strings, aka `10k_sales_records_non_unique.xlsx`, simple_xlsx_reader and creek are neck and neck:

| Gem                | Parses/second | RSS Increase | Allocated Mem | Retained Mem | Allocated Objects | Retained Objects |
|--------------------|---------------|--------------|---------------|--------------|-------------------|------------------|
| creek              | 1.32          | 36.06mb      | 520.48mb      | 3.2kb        | 6613688           | 15               |
| simple_xlsx_reader | 1.3           | 34.31mb      | 563.62mb      | 1.13kb       | 8056277           | 3                |
| roo                | 0.86          | 54.53mb      | 141.48mb      | 2.18kb       | 1895656           | 4                |
| xsv                | 0.76          | 43.0mb       | 1893.92mb     | 3.9kb        | 5483908           | 10               |
| rubyxl             | 0.3           | 359.95mb     | 662.25mb      | 2.18kb       | 9822929           | 4                |

Then there's the really big file, `300k_sales_records.xlsx`, which similar to our first example also has lots of unique strings (note, omitting MemoryProfiler results because it has too much overhead for this test, and changing parses/second to total time for a single parse):

| Gem                | Time    | RSS Increase |
|--------------------|---------|--------------|
| simple_xlsx_reader | 28.32s  | 95.66mb      |
| roo                | 43.05s  | 900.86mb     |
| creek              | 48.41s  | 820.64mb     |
| xsv                | 50.09s  | 272.97mb     |
| rubyxl             | 278.47s | 3423.31mb    |

Also, here's the results from a real-world file I can't share, but was 26mb and
a big portion of shared strings:

| Gem                | Time    | RSS Increase |
|--------------------|---------|--------------|
| simple_xlsx_reader | 28.71s  | 148.77mb     |
| roo                | 40.25s  | 1322.08mb    |
| xsv                | 45.82s  | 391.27mb     |
| creek              | 60.63s  | 886.81mb     |
| rubyxl             | 238.68s | 9136.3mb     |

