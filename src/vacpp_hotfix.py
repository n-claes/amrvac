from argparse import ArgumentParser
from tempfile import mkstemp

import os
import shutil

def main():
    parser = ArgumentParser(description="Fortran file to check for single ampersands")
    parser.add_argument('-f', '--fortran_file', dest='fortran_file')
    args = parser.parse_args()
    filepath = args.fortran_file

    single_amps = []
    amps_to_append = []
    commas_before_assign = []
    trailing_amps = []

    with open(filepath, 'r') as original_file:
        prev_line = ''
        for line_nb, line in enumerate(original_file, 1):
            curr_line = line.strip()

            # check for single & on a line
            if len(curr_line) == 1 and '&' in curr_line:
                single_amps.append(line_nb)

            # check if line starts with a comma, and previous line has no &
            if curr_line.startswith(',') and not prev_line.endswith('&'):
                # check if this is an assignment with leading comma
                if '=' in curr_line:
                    commas_before_assign.append(line_nb)
                else:
                    amps_to_append.append(line_nb - 1)

            # check if there are trailing &'s (white line after)
            if curr_line == '' and prev_line.endswith('&'):
                trailing_amps.append(line_nb - 1)

            prev_line = curr_line
        original_file.close()

    if single_amps or amps_to_append or commas_before_assign or trailing_amps:
        print("")
        if single_amps:
            print(">>> WARNING ({}): commented single ampersand on lines {}".format(filepath, single_amps))
        if amps_to_append:
            print(">>> WARNING ({}): inserted missing ampersand on lines {}".format(filepath, amps_to_append))
        if commas_before_assign:
            print(">>> WARNING ({}): removed leading commas before "
                  "assignment on lines {}".format(filepath, commas_before_assign))
        if trailing_amps:
            print(">>> WARNING ({}): removed trailing ampersand before empty line "
                  "on lines {}".format(filepath, trailing_amps))
        print("")

        file_handler, abs_path = mkstemp()
        with os.fdopen(file_handler, 'w') as new_file:
            with open(filepath) as original_file:
                for line_nb, line in enumerate(original_file, 1):
                    if line_nb in single_amps:
                        new_line = ''.join(['!', line.rstrip(), '\n'])
                    elif line_nb in trailing_amps:
                        new_line = ''.join([line.rstrip()[:-1], '\n'])
                    elif line_nb in commas_before_assign:
                        new_line = ''.join([line.lstrip()[1:], '\n'])
                    elif line_nb in amps_to_append:
                        new_line = ''.join([line.rstrip(), ' &', '\n'])
                    else:
                        new_line = line
                    new_file.write(new_line)
                original_file.close()
            new_file.close()

        # copy permissions
        shutil.copymode(filepath, abs_path)
        # remove old file
        os.remove(filepath)
        # save new file
        shutil.move(abs_path, filepath)

if __name__ == '__main__':
    main()
