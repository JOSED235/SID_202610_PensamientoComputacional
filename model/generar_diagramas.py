"""Genera MR_3FN.dot y MER_conceptual.dot (Graphviz) desde el diccionario de datos de Oracle.

Uso: python model/generar_diagramas.py <carpeta_salida>
Conexion por variables de entorno ORA_USER, ORA_PASSWORD y ORA_DSN (por defecto, el contenedor de prueba local).
Los .dot se dibujan con Graphviz (motor neato, posiciones fijas y lineas ortogonales).
"""
import os, sys, oracledb
out = sys.argv[1]
con = oracledb.connect(user=os.environ.get('ORA_USER', 'sid'), password=os.environ.get('ORA_PASSWORD', 'sid'),
                       dsn=os.environ.get('ORA_DSN', 'localhost:15210/FREEPDB1'))
cur = con.cursor()

cur.execute("""select c.table_name, c.column_name, c.data_type, c.data_length, c.data_precision, c.nullable
               from user_tab_columns c join user_tables t on t.table_name = c.table_name
               order by c.table_name, c.column_id""")
cols = {}
for t, c, dt, ln, pr, nl in cur.fetchall():
    cols.setdefault(t, []).append((c, dt, ln, pr, nl))
cur.execute("""select uc.constraint_type, ucc.table_name, ucc.column_name
               from user_constraints uc join user_cons_columns ucc on ucc.constraint_name = uc.constraint_name
               where uc.constraint_type in ('P','R','U')""")
keys = {}
for ctype, t, c in cur.fetchall():
    keys.setdefault((t, c), set()).add({'P': 'PK', 'R': 'FK', 'U': 'UK'}[ctype])
cur.execute("""select fk.table_name, fcc.column_name, pk.table_name,
                      (select nullable from user_tab_columns x where x.table_name = fk.table_name and x.column_name = fcc.column_name)
               from user_constraints fk
               join user_constraints pk on pk.constraint_name = fk.r_constraint_name
               join user_cons_columns fcc on fcc.constraint_name = fk.constraint_name
               where fk.constraint_type = 'R' order by 1, 2""")
fks = cur.fetchall()
cur.execute("""select ucc.table_name, ucc.column_name from user_constraints uc
               join user_cons_columns ucc on ucc.constraint_name = uc.constraint_name
               where uc.constraint_type = 'U'
                 and (select count(*) from user_cons_columns x where x.constraint_name = uc.constraint_name) = 1""")
single_uk = set(cur.fetchall())
assert len(cols) == 16 and len(fks) == 20, (len(cols), len(fks))

MODULE = {
    'USER_TYPE': 'dom', 'USER_STATUS': 'dom', 'ACTIVITY_STATUS': 'dom', 'DIFFICULTY_SCALE': 'dom',
    'APP_USER': 'usr', 'ADMINISTRATOR': 'usr', 'PROFESSOR': 'usr', 'STUDENT': 'usr', 'LEVEL_RANK': 'usr',
    'SEMESTER': 'cur', 'COURSE_GROUP': 'cur', 'ENROLLMENT': 'cur',
    'EXERCISE': 'act', 'ACTIVITY': 'act', 'ACTIVITY_EXERCISE': 'act', 'SCORE': 'act',
}
STYLE = {  # color de encabezado, color de texto del encabezado, nombre del modulo
    'dom': ('#8A93B8', 'white', 'Dominios'), 'usr': ('#2E3560', 'white', 'Usuarios'),
    'cur': ('#1B998B', 'white', 'Cursos'), 'act': ('#F2A541', '#1B1F3B', 'Actividades y puntajes'),
}
INK = '#1B1F3B'

def typ(dt, ln, pr):
    if dt == 'VARCHAR2': return f'VARCHAR2({ln})'
    if dt.startswith('TIMESTAMP'): return 'TIMESTAMP'
    if dt == 'NUMBER' and pr: return f'NUMBER({pr})'
    return dt

def header(t, label):
    bg, fg, _ = STYLE[MODULE[t]]
    return f'<TR><TD COLSPAN="3" BGCOLOR="{bg}" ALIGN="CENTER"><FONT COLOR="{fg}" POINT-SIZE="13"><B>{label}</B></FONT></TD></TR>'

def graph_head(title, splines='ortho'):
    return [
        'digraph G {',
        f'  graph [rankdir=LR, splines={splines}, nodesep=0.55, ranksep=1.1, pad=0.3, bgcolor="white", fontname="Calibri", '
        f'label=<<FONT POINT-SIZE="18"><B>{title}</B></FONT>>, labelloc=t, labeljust=l, newrank=true, forcelabels=true];',
        f'  node [shape=plaintext, fontname="Calibri", fontsize=11, fontcolor="{INK}"];',
        f'  edge [color="#5B6379", penwidth=1.3, dir=both, arrowsize=0.9, fontname="Calibri", fontsize=10, fontcolor="#2E3560"];',
    ]

def legend(lines):
    rows = ''.join(f'<TR><TD ALIGN="LEFT">{l}</TD></TR>' for l in lines)
    mods = ''.join(f'<TD BGCOLOR="{bg}"><FONT COLOR="{fg}"> {name} </FONT></TD>' for bg, fg, name in STYLE.values())
    return (f'  legend [label=<<TABLE BORDER="1" CELLBORDER="0" CELLSPACING="2" CELLPADDING="3" COLOR="#C9CEDF">'
            f'<TR><TD ALIGN="LEFT"><B>Convenciones</B></TD></TR><TR><TD><TABLE BORDER="0" CELLSPACING="3"><TR>{mods}</TR></TABLE></TD></TR>{rows}</TABLE>>];')

# Posiciones fijas (pulgadas, centro del nodo): columnas por modulo, de izquierda a derecha
POS = {
    'USER_STATUS': (1.3, 9.2), 'USER_TYPE': (1.3, 6.6),
    'APP_USER': (5.0, 7.9),
    'ADMINISTRATOR': (9.0, 11.0), 'PROFESSOR': (9.0, 8.5), 'STUDENT': (9.0, 4.7), 'LEVEL_RANK': (9.0, 1.7),
    'SEMESTER': (13.0, 10.6), 'COURSE_GROUP': (13.0, 7.3), 'ENROLLMENT': (13.0, 4.0),
    'ACTIVITY_STATUS': (17.0, 11.2), 'ACTIVITY': (17.0, 7.9), 'EXERCISE': (17.0, 3.4),
    'ACTIVITY_EXERCISE': (21.0, 7.4), 'DIFFICULTY_SCALE': (21.0, 1.7),
    'SCORE': (24.9, 4.4), 'legend': (23.6, 10.9),
}
def ranks(over=None):
    pos = dict(POS, **(over or {}))
    return [f'  {t} [pos="{x},{y}!"];' for t, (x, y) in pos.items()]


# ---------------- Modelo relacional ----------------
L = graph_head('Modelo relacional normalizado (3FN) · Plataforma de gamificación')
for t, cs in cols.items():
    rows = [header(t, t)]
    for c, dt, ln, pr, nl in cs:
        k = keys.get((t, c), set())
        tag = ', '.join(x for x in ('PK', 'FK', 'UK') if x in k)
        name = f'<B>{c.lower()}</B>' if 'PK' in k else (f'<I>{c.lower()}</I>' if 'FK' in k else c.lower())
        null = '' if nl == 'N' else ' <FONT COLOR="#8A93B8">null</FONT>'
        rows.append(f'<TR><TD ALIGN="LEFT" WIDTH="22">{f'<FONT COLOR="#1B998B"><B>{tag}</B></FONT>' if tag else ' '}</TD>'
                    f'<TD ALIGN="LEFT">{name}</TD><TD ALIGN="LEFT"><FONT COLOR="#5B6379">{typ(dt, ln, pr)}</FONT>{null}</TD></TR>')
    L.append(f'  {t} [label=<<TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" CELLPADDING="4" COLOR="#9AA1BD" BGCOLOR="white">{"".join(rows)}</TABLE>>];')
for child, col, parent, nullable in fks:
    one_to_one = 'PK' in keys.get((child, col), set())
    tail = 'teetee' if nullable == 'N' else 'teeodot'
    head = 'teeodot' if one_to_one else 'crowodot'
    L.append(f'  {parent} -> {child} [arrowtail={tail}, arrowhead={head}];')
L.append(legend(['<B>PK</B>: llave primaria · <I>FK</I>: llave foránea · UK: parte de una restricción única · null: admite nulos',
                 'Línea: ┼ uno obligatorio · o┼ cero o uno · o&lt; cero o muchos (pata de gallo)']))
L += ranks()
L.append('}')
open(f'{out}/MR_3FN.dot', 'w', encoding='utf8').write('\n'.join(L))

# ---------------- MER conceptual ----------------
# Atributos sin FK, con identificador (#) y obligatorio (*) / opcional (o) en notacion Barker
VERB = {
    ('USER_TYPE', 'APP_USER'): 'clasifica', ('USER_STATUS', 'APP_USER'): 'define estado',
    ('APP_USER', 'ADMINISTRATOR'): 'es un', ('APP_USER', 'PROFESSOR'): 'es un', ('APP_USER', 'STUDENT'): 'es un',
    ('LEVEL_RANK', 'STUDENT'): 'categoría actual', ('LEVEL_RANK', 'EXERCISE'): 'perfil objetivo',
    ('SEMESTER', 'COURSE_GROUP'): 'oferta', ('PROFESSOR', 'COURSE_GROUP'): 'dicta',
    ('STUDENT', 'ENROLLMENT'): 'se matricula', ('COURSE_GROUP', 'ENROLLMENT'): 'recibe',
    ('COURSE_GROUP', 'ACTIVITY'): 'tiene', ('PROFESSOR', 'ACTIVITY'): 'crea', ('ACTIVITY_STATUS', 'ACTIVITY'): 'define estado',
    ('ACTIVITY', 'ACTIVITY_EXERCISE'): 'agrupa', ('EXERCISE', 'ACTIVITY_EXERCISE'): 'se usa en',
    ('DIFFICULTY_SCALE', 'EXERCISE'): 'mide', ('ACTIVITY_EXERCISE', 'SCORE'): 'se califica con',
    ('STUDENT', 'SCORE'): 'obtiene', ('PROFESSOR', 'SCORE'): 'asigna',
}
ES = {'APP_USER': 'USUARIO', 'ADMINISTRATOR': 'ADMINISTRADOR', 'PROFESSOR': 'PROFESOR', 'STUDENT': 'ESTUDIANTE',
      'USER_TYPE': 'TIPO_USUARIO', 'USER_STATUS': 'ESTADO_USUARIO', 'LEVEL_RANK': 'CATEGORIA', 'SEMESTER': 'SEMESTRE',
      'COURSE_GROUP': 'GRUPO', 'ENROLLMENT': 'MATRICULA', 'EXERCISE': 'EJERCICIO', 'DIFFICULTY_SCALE': 'DIFICULTAD',
      'ACTIVITY': 'ACTIVIDAD', 'ACTIVITY_STATUS': 'ESTADO_ACTIVIDAD', 'ACTIVITY_EXERCISE': 'EJERCICIO_ACTIVIDAD', 'SCORE': 'PUNTAJE'}
L = graph_head('Modelo entidad-relación (conceptual) · Plataforma de gamificación')
for t, cs in cols.items():
    rows = [header(t, f'{ES[t]}<BR/><FONT POINT-SIZE="9">{t}</FONT>')]
    for c, dt, ln, pr, nl in cs:
        k = keys.get((t, c), set())
        if 'FK' in k and 'PK' not in k: continue
        if 'PK' in k and t in ('ADMINISTRATOR', 'PROFESSOR', 'STUDENT'):
            mark, name = '#', f'<B>{c.lower()}</B> <FONT COLOR="#8A93B8">(heredado)</FONT>'
        else:
            mark = '#' if 'PK' in k else ('*' if nl == 'N' else 'o')
            name = f'<B>{c.lower()}</B>' if 'PK' in k else c.lower()
        uk = ' <FONT COLOR="#1B998B">único</FONT>' if (t, c) in single_uk else ''
        rows.append(f'<TR><TD ALIGN="CENTER" WIDTH="16"><FONT COLOR="#1B998B"><B>{mark}</B></FONT></TD><TD ALIGN="LEFT" COLSPAN="2">{name}{uk}</TD></TR>')
    L.append(f'  {t} [label=<<TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" CELLPADDING="4" COLOR="#9AA1BD" BGCOLOR="white" STYLE="ROUNDED">{"".join(rows)}</TABLE>>];')
for child, col, parent, nullable in fks:
    one_to_one = 'PK' in keys.get((child, col), set())
    tail = 'teetee' if nullable == 'N' else 'teeodot'
    head = 'teeodot' if one_to_one else ('crowtee' if (parent, child) == ('ACTIVITY', 'ACTIVITY_EXERCISE') else 'crowodot')
    style = ', style=dashed, color="#2E3560"' if one_to_one else ''
    L.append(f'  {parent} -> {child} [arrowtail={tail}, arrowhead={head}, {'taillabel' if (parent, child) == ('PROFESSOR', 'ACTIVITY') else 'xlabel'}="{VERB[(parent, child)]}", labeldistance=3.2, labelangle=25{style}];')
L.append(legend(['# identificador · * obligatorio · o opcional', 'Línea punteada: jerarquía USUARIO (supertipo) y sus subtipos',
                 'Línea: ┼ uno obligatorio · o┼ cero o uno · o&lt; cero o muchos · ┼&lt; uno o muchos']))
L += ranks({'SCORE': (26.2, 6.3), 'USER_STATUS': (0.6, 9.2), 'USER_TYPE': (0.6, 6.6)})
L.append('}')
open(f'{out}/MER_conceptual.dot', 'w', encoding='utf8').write('\n'.join(L))
print('ok')
