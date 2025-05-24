#!/usr/bin/env python3
import pandas as pd
import argparse
import os
import datetime
import subprocess

def first_check(input):
    print("Firstly, we're checking if formatting is fine.")
    #ошибка: существует ли файл
    if not os.path.exists(input):
        raise FileNotFoundError(f"Error: The file '{input}' does not exist.")

    #ошибка: формат файла
    with open(input) as f:
        first_line = f.readline()

        #блок проверки на наличие ключевых колонок и исключения "мусора"
        required_columns = ['#CHROM', 'POS', 'ID', 'allele1', 'allele2']

        first_line_list = first_line.rstrip('\n').split(sep='\t')
        first_line_list = [item.replace(' ', '') for item in first_line_list]

        if all(col in first_line_list for col in required_columns):
            print("Formatting is fine.")
        else:
            raise ValueError("Some essential columns are missing: '#CHROM', 'POS', 'ID', 'allele1', 'allele2'.")
        
        #получение индексов колонок
        l = []
        for col in required_columns:
            col_index = first_line_list.index(col) + 1  #т.к. индексация с 0
            l.append(col_index)

        #формирование команды awk для выделения столбцов согласно названиям
        command = ', '.join([f'${i}' for i in l])
        awk_command = f"awk -F '\\t' 'BEGIN{{OFS=\"\\t\"}} {{print {command}}}' {input} > temp.txt"

        #запуск команды в командной строке
        subprocess.run(awk_command, shell=True, capture_output=True, text=True)
        #конец блока


    del f, first_line

def comparison(g, a1, a2): #функция для сравнения референса и аллелей
        if g == a1 and g == a2:
            return None
        elif g != a1 and g == a2:
            return a1
        elif g == a1 and g != a2:
            return a2
        else:
            return a1, a2

def main():
    #задаем описание и аргументы для скрипта
    parser = argparse.ArgumentParser(description="This file allows to find reference nucleotides from GRCh38 and " \
    "reveal which of the two alleles are alternative (maybe both). To use this script please use a file" \
    " containing tab as a separator and columns: #CHROM', 'POS', 'ID', 'allele1', 'allele2', where #CHROM is a " \
    "chromosome number, POS - is a position of a target nucleotide, ID - ID of this nucleotide, " \
    " allele1/2 - the first and second allele nucleotides of interest respectively.")
    parser.add_argument("--input", help="The input file",  required=True)
    parser.add_argument("--output", help="The output file", default='output.tsv')

    args = parser.parse_args()

    first_check(args.input)

    #snp = pd.read_csv(args.input, sep='\t') #изначально
    snp = pd.read_csv('temp.txt', sep='\t')

    print('File is uploaded.')

    snp = snp.drop(snp.loc[snp['#CHROM'] == 23].index) #Удаляем SNP из Х хромосомы согласно заданию
    snp.columns = [item.replace(' ', '') for item in snp.columns]
    snp['REF'] = None
    snp['ALT'] = None

    chr_list = list(range(1, 23)) #не рассматриваем 'X', 'Y', 'M', согласно заданию

    print("We're starting to set reference nucleotides.", datetime.datetime.now())

    for i in chr_list:
        with open(f'/ref/GRCh38.d1.vd1_mainChr/sepChrs/chr{i}.fa', 'rt') as file:
            #пропустить первую строчку
            next(file)
            chr = []
            
            for line in file:
                chr.append(line.strip())
        chr = ''.join(chr)

        for index, row in snp.iterrows():
            if row['#CHROM'] == i:
                snp.at[index, 'REF'] = chr[row['POS']]
    del chr

    print("We're setting alternative nucleotides.", datetime.datetime.now())

    snp['ALT'] = snp.apply(lambda row: comparison(row['REF'], row['allele1'], row['allele2']), axis=1)

    print("Saving output file. Bye!")

    snp[['#CHROM', 'POS', 'ID', 'REF', 'ALT']].to_csv(args.output, sep='\t') #оставляем только нужные столбцы

    subprocess.run('rm temp.txt', shell=True, capture_output=True, text=True) #удаляем временный файл

if __name__ == "__main__":
    main()
