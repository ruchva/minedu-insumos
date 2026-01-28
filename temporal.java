    @Override
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, FilterChain chain,
                    Authentication authResult) throws IOException, ServletException {

        org.springframework.security.core.userdetails.User user = (org.springframework.security.core.userdetails.User) authResult
                .getPrincipal();
        String username = user.getUsername();
        Optional<UsuarioEntity> usuarioOptional = usuarioRepository.findByUsuario(username);
        if (usuarioOptional.isEmpty()) {
            unsuccessfulAuthentication(request, response,
                    new AuthenticationException("Usuario no encontrado después de la autenticación") {});
            return;
        }
        UsuarioEntity usuario = usuarioOptional.get();

        // Verificar que usuarioRoles no sea null y obtener rol activo de forma segura
        UsuarioRolEntity rolActivo = null;
        if (usuario.getUsuarioRoles() != null && !usuario.getUsuarioRoles().isEmpty()) {
            rolActivo = usuario.getUsuarioRoles().stream().findFirst().orElse(null);
        }

        Collection<? extends GrantedAuthority> authorities = authResult.getAuthorities();
        List<String> roles = authorities.stream().map(GrantedAuthority::getAuthority).collect(Collectors.toList());

        Map<String, Object> claims = new HashMap<>();
        claims.put("id", usuario.getId().toString());
        claims.put("roles", roles);
        claims.put("idRol", rolActivo != null && rolActivo.getRol() != null ? rolActivo.getRol().getId().toString() : null);
        claims.put("rol", rolActivo != null && rolActivo.getRol() != null ? rolActivo.getRol().getRol() : null);

        String jwt = jwtUtil.generateToken(claims, username, new Date(System.currentTimeMillis() + 3600000)); // 1 hora

        // Construir DTOs sin referencias circulares
        List<RoleTypeDto> rolesDto = new ArrayList<>();
        if (usuario.getUsuarioRoles() != null) {
            for (UsuarioRolEntity usuarioRol : usuario.getUsuarioRoles()) {
                if (usuarioRol.getRol() != null) {
                    List<PermisoModuloTypeDto> modulos = moduloService.obtenerModulosSubmodulos(usuarioRol.getRol().getRol());

                    // Si el rol es 'DIR' (ID 9), agregamos los paralelos como submódulos.
                    if (rolActivo != null && rolActivo.getRol() != null && "9".equals(rolActivo.getRol().getId().toString())) {
                        ArrayList<String> cod_sie_ue = moduloService.obtenerUEDirector(usuario.getId().intValue());
                        if (cod_sie_ue != null && !cod_sie_ue.isEmpty()) {
                            //lista de paralelos (primer colegio por defecto)
                            List<ParaleloTypeDto> paralelos = moduloService.obtenerParalelosDirector(usuario.getId().intValue(), Integer.parseInt(cod_sie_ue.get(0)));
                            List<SubModuloTypeDto> subModulosParalelos = paralelos.stream()
                                            .map(paralelo -> {
                                                    PropiedadesModuloDto props = new PropiedadesModuloDto();
                                                    props.setDescripcion("Estudiantes del Paralelo " + paralelo.getParalelo());
                                                    props.setIcono("assignment_ind");
                                                    // La URL debe coincidir con la ruta del frontend para ver un paralelo.
                                                    return new SubModuloTypeDto(
                                                                    Long.valueOf(paralelo.getId()),
                                                                    "ACTIVO",
                                                                    "Paralelo " + paralelo.getParalelo(),
                                                                    "/director-ue/paralelos/" + paralelo.getParalelo(),
                                                                    "Paralelo " + paralelo.getParalelo(),
                                                                    props);
                                            }).collect(Collectors.toList());
                            // Buscar el módulo padre "Unidades Educativas" para agregar los paralelos.
                            // El label a buscar ("Unidades Educativas") depende de cómo esté en la BD.
                            modulos.stream().filter(module -> "Unidad Educativa".equals(module.getLabel()))
                                            .findFirst().ifPresent(moduloUE -> moduloUE.getSubModulo().addAll(subModulosParalelos));
                        }
                    }

                    RoleTypeDto roleDto = RoleTypeDto.builder()
                                    .idRol(usuarioRol.getRol().getId().toString())
                                    .rol(usuarioRol.getRol().getRol())
                                    .nombre(usuarioRol.getRol().getNombre())
                                    .descripcion(usuarioRol.getRol().getDescripcion())
                                    .modulos(modulos) // permisos
                                    .build();
                    rolesDto.add(roleDto);
                }
            }
        }

        PersonaEntity persona = usuario.getPersona();
        PersonaTypeDto personaDto = new PersonaTypeDto();
        if (persona != null) {
            personaDto.setNombres(persona.getNombres());
            personaDto.setPrimerApellido(persona.getPrimerApellido());
            personaDto.setSegundoApellido(persona.getSegundoApellido());
            personaDto.setTipoDocumento(persona.getTipoDocumento());
            personaDto.setNroDocumento(persona.getNroDocumento());
            // Revisar: personaDto.setFechaNacimiento(persona.getFechaNacimiento());
        }

        AuthDataDto authData = AuthDataDto.builder()
                .access_token(jwt)
                .id(usuario.getId().toString())
                .usuario(usuario.getUsuario())
                .ciudadaniaDigital(false)
                .correoElectronico(usuario.getCorreoElectronico())
                .idDepartamento(usuario.getPersona().getIdDepartamento())
                .idDistrito(usuario.getPersona().getIdDistrito())
                .urlFoto(null)
                .estado(usuario.getEstado().toString())
                .tieneFirmaDigital(!softkeyTokenRepository.findByUsername(username).isEmpty())
                .roles(rolesDto)
                .idRol(rolActivo != null && rolActivo.getRol() != null ? rolActivo.getRol().getId().toString() : null)
                .rol(rolActivo != null && rolActivo.getRol() != null ? rolActivo.getRol().getRol() : null)
                .persona(personaDto)
                .build();

        AuthResponseDto authResponse = AuthResponseDto.builder()
                .finalizado(true)
                .mensaje("ok")
                .datos(authData)
                .build();

        //response.getWriter().write(new ObjectMapper().writeValueAsString(authResponse));
        response.getWriter().write(objectMapper.writeValueAsString(authResponse));
        response.setContentType(CONTENT_TYPE);
        response.setStatus(200);
    }