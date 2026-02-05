                    // quiero aclarar que jimi juro que esta validacion no existia
                    // en fecha 2 de febrero del 2026, Sam como testigo
                    // obj.setEstadoFirmarActa(obj.getRevisionTecnica().equals(obj.getTotalEstudiantes()));
                    obj.setEstadoFirmarActa(obj.getRevisionTecnica() > 0 ? true : false);
