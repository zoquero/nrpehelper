# NRPE helper
This small repository offers some useful examples and tools for developing NRPE scripts that can be used to extract monitoring metrics from any Nagios-like monitoring platform.

It contains:
- Sample NRPE bash scripts:
   - files ** `simple_nrpe_plugin*.sh` **
- Output of existing NRPE plugins:
   - files ** `sample_output*.txt` **
- NRPE output validator, written in Python3:
   - file ** `nrpeov.py` **

So, once you know how to extract a metric, in order to build it as a NRPE script you can, for example:
1. Read the docs like [Nagios Plugins Development Guidelines](https://nagios-plugins.org/doc/guidelines.html)
2. Read some samples of output (files ** `sample_output*.txt` **)
3. Read some samples of scripts (files ** `simple_nrpe_plugin*.sh` **)
4. Write your script
5. Test you script using the script ** `nrpeov.py` ** like this:

    ./your_nrpe_script | python3 nrpeov.py


/ Angel Galindo Muñoz, July 2023
