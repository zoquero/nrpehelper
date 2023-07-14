""" Script that parses the output of a NRPE command and shows
    its 'detailed description' and metrics (if there's 'perfdata').

    Angel Galindo Muñoz
    July the 11th of 2023
"""

import sys
import re
import pprint

def parse_nrpe_output(output):

    """ Function that reads a string, parses the output of a NRPE command and returns a dict with two components: 'description' (with the 'detailed description') and 'perfdata' that's a dict with the components 'label', 'value', 'unit', 'warn', 'crit', 'min' and 'max'. """

    a = []
#   result = { 'description': None, 'perfdata': None, 'rest': None }
    result = {}
    max_iterations = 400
    perfdata_array = []

    # Pattern to extract the perfdata unit
    pattern_perfdata_val_unit = r"^([-+]?[\d.]+)(.*)$"

    if(not output):
        return result

    splitted_output=output.split('\n', 1)
    if(len(splitted_output) < 1):
        return result
    elif(len(splitted_output) == 1):
        result['rest'] = ''
    else:
        result['rest'] = splitted_output[1]

    a = splitted_output[0].split('|')
    if(not a):
        return result
    if(len(a) == 1):
        result['description'] = a[0]
        result['perfdata']    = {}
        return result
    else:
        result['description'] = a[0]
        a = a[1]
        done = False;
        for i in range(max_iterations):
            a = a.split('=', 1)
            if(len(a) < 2):
                print("WARNING: perfdata without '=', it seems malformed:")
                pprint.pprint(a)
                print("")
                break

            # 1st component is the label for the next metric
            # 2nd component is the perfdata for the next metric plus (maybe)
            #               a blank space and the rest of
            #               label=perfdata , label=perfdata , label=perfdata , ...

            label = a.pop(0).strip()
            d     = a[0].strip()

            # if 'd' contains a blank space then there are more perfdata
            if(bool(re.search(r"\s", d))):
                # Let's separate the new perfdata to analyze it in this iteration
                # and let's move the rest for the next iteration
                parts = d.split(' ', 1)
                d = parts[0]
                a = parts[1]
            else:
                done = True;

            pdm_val  = ''
            pdm_warn = ''
            pdm_crit = ''
            pdm_min  = ''
            pdm_max  = ''
            val_value = ''
            val_unit  = ''
 
            pdvs = d.split(';')
            if pdvs:
                pdm_val  = pdvs[0] if(len(pdvs) > 0) else ''
                pdm_warn = pdvs[1] if(len(pdvs) > 1) else ''
                pdm_crit = pdvs[2] if(len(pdvs) > 2) else ''
                pdm_min  = pdvs[3] if(len(pdvs) > 3) else ''
                pdm_max  = pdvs[4] if(len(pdvs) > 4) else ''

                match_description = re.search(pattern_perfdata_val_unit, pdm_val)
                val_value = match_description.group(1).strip()
                val_unit  = match_description.group(2).strip()

            a_perfdata_dit = {
                                 'label' : label,
                                 'value' : val_value,
                                 'unit'  : val_unit,
                                 'warn'  : pdm_warn,
                                 'crit'  : pdm_crit,
                                 'min'   : pdm_min,
                                 'max'   : pdm_max
            }
            perfdata_array.append(a_perfdata_dit)
            if(done):
                break
 
        result['perfdata'] = perfdata_array
    return result


# Let's read from standard input:
nrpe_output = sys.stdin.read()

# Let's parse it
parsed_output = parse_nrpe_output(nrpe_output)

# Let's print results:

s = parsed_output.get('description')
print("Detailed description (next line):\n{}\n".format(s))

print("Perfdata: (next lines)")
i = 0
for a_perfdata in parsed_output.get('perfdata'):
    print("* perfdata for metric #{}:".format(i))
    pprint.pprint(a_perfdata)
    print("");
    i=i+1
if(i == 0):
    print("(no perfdata)")

rest=parsed_output.get('rest')
if(not rest):
    print("There's just one line (correct)")
else:
    print("There's more than one line of output, this is discouraged. It's this: (next lines)")
    print(rest)

