def table_to_sql(table, n_row=True):
    res = '\n' if n_row else ''
    res += table[0].to_sql()
    lid = 0
    for v in range(1, len(table)):
        if v - lid < 950:
            res += ','
            res += table[v].to_sql(False)
        else:
            res += '\n'
            res += table[v].to_sql()
            lid = v
    return res
