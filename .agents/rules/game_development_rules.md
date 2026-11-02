---
trigger: always_on
description: Mandatory development guidelines from CONTEXTO.md for the 5-microgame Flutter + Flame pack.
---

# Reglas de Desarrollo del Proyecto (CONTEXTO.md)

1. **Un solo juego a la vez**: Desarrollar e iterar un juego funcional antes de pasar al siguiente (iniciar con Orbit Break).
2. **Sin dependencias innecesarias**: Mantener un número mínimo de dependencias externas. No usar bibliotecas pesadas de física si un movimiento determinista simple es suficiente.
3. **Estilo Vectorial Minimalista**: Dibujo geométrico programático (círculos, líneas, polígonos) reutilizando `Paint`. Evitar texturas o sprites pesados.
4. **Independencia del Framerate**: Toda actualización física o espacial debe multiplicarse por `dt` (`update(double dt)`).
5. **Aislamiento por Juego**: Cada juego debe vivir en su propio directorio `lib/games/<juego>/` y no depender de clases internas de otros juegos.
6. **Entrada Unificada**: El juego debe soportar teclado (PC/Steam) y toques (Mobile/Android) compartiendo la misma lógica interna.
7. **Control y Persistencia 100% Local (Offline Estricto)**: La aplicación debe ser completamente autónoma tras su descarga e instalación. Queda terminantemente prohibido incorporar servidores, llamadas a APIs remotas, descargas en segundo plano, autenticación en la nube, analíticas de red, anuncios o compras in-app. Todos los recursos (audio, gráficos, código) van empaquetados en el instalador y los datos se guardan exclusivamente en el dispositivo.
8. **Pruebas y Verificación**: Todo código entregado debe incluir pruebas unitarias para reglas y estados, compilar limpiamente y pasar `dart analyze`.
9. **Informes de Avance**: Cada fase completada debe reportarse en español siguiendo el formato de 10 puntos de la Sección 15 de CONTEXTO.md.
