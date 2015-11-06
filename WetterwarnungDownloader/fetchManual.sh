#!/bin/bash

# Zugangsdaten zum DWD Grundversorgungs-Server
FTPUSER="**********"
FTPPASSWD="********"

echo Starte Download der WarnCellID Liste:
wget ftp://$FTPUSER:$FTPPASSWD@ftp-outgoing2.dwd.de/gds/specials/warnings/legend_warnings.pdf

echo Starte Download der restlichen Entwickler-Dokumentation vom DWD:
wget ftp://$FTPUSER:$FTPPASSWD@ftp-outgoing2.dwd.de/gds/specials/legend_basic_service_level.pdf
wget https://werdis.dwd.de/infos/legend_warnings_CAP.pdf

exit 0