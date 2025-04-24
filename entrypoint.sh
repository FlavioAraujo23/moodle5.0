#!/bin/bash
set -e

# Aguardar o banco de dados iniciar
echo "Aguardando o banco de dados..."
sleep 10

# Verificar se o config.php já existe
if [ ! -f /var/www/html/config.php ]; then
    echo "Criando configuração inicial do Moodle..."
    
    # Criar config.php
    cat > /var/www/html/config.php << EOF
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'mariadb';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '${MOODLE_DB_HOST}';
\$CFG->dbname    = '${MOODLE_DB_NAME}';
\$CFG->dbuser    = '${MOODLE_DB_USER}';
\$CFG->dbpass    = '${MOODLE_DB_PASSWORD}';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array(
    'dbpersist' => false,
    'dbsocket'  => false,
    'dbport'    => ${MOODLE_DB_PORT},
    'dbcollation' => 'utf8mb4_unicode_ci'
);

\$CFG->wwwroot   = '${MOODLE_URL}';
\$CFG->dataroot  = '/var/www/moodledata';
\$CFG->directorypermissions = 02777;
\$CFG->admin = 'admin';

require_once(__DIR__ . '/lib/setup.php');
EOF

    chown www-data:www-data /var/www/html/config.php
fi

# Definir permissões corretas
chown -R www-data:www-data /var/www/html /var/www/moodledata

# Executar o comando fornecido
exec "$@"
