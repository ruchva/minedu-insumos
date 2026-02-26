## ¿Qué es **Qwik**?

**Qwik** es un **framework frontend** creado por el mismo equipo de **Angular**, pero pensado para una idea muy radical:

👉 **cargar casi cero JavaScript al inicio**.

Su objetivo principal es que las páginas web **abran instantáneamente**, incluso en conexiones lentas.

---

## La idea clave de Qwik (lo que lo hace distinto)

### 🔥 *Resumability* (su superpoder)

En lugar de:

* cargar JS
* hidratar la app
* ejecutar todo otra vez en el navegador

Qwik:

* **“reanuda”** la app exactamente donde el servidor la dejó
* descarga **solo el JS que se necesita**, **cuando se necesita**

📦 Resultado:

* Time To Interactive casi inmediato
* Menos CPU
* Menos batería
* Mejor SEO y Core Web Vitals

---

## ¿Cómo funciona en la práctica?

* El HTML viene ya “listo para interactuar”
* Los eventos (`onClick`, `onInput`, etc.) se cargan **lazy**
* Cada componente puede descargarse de forma independiente

Ejemplo mental:

> Haces clic en un botón → solo se descarga el JS de *ese botón*, no de toda la app.

---

## Qwik vs lo que ya conoces

| Framework | Hidratación | JS inicial    |
| --------- | ----------- | ------------- |
| React     | Sí          | Alto          |
| Vue       | Sí          | Medio         |
| Angular   | Sí          | Alto          |
| **Qwik**  | ❌ No        | **Casi cero** |
| Astro     | Parcial     | Bajo          |

👉 **Astro** reduce JS
👉 **Qwik** casi lo elimina

---

## Qwik + Qwik City

* **Qwik** → framework base
* **Qwik City** → router, SSR, SSG, endpoints, middleware (tipo Next.js)

Muy parecido a:

* Next.js (pero más liviano)
* Remix (pero más agresivo con performance)

---

## ¿Cuándo conviene usar Qwik?

✅ Landing pages ultra rápidas
✅ Apps públicas con mucho tráfico
✅ SEO crítico
✅ Dispositivos móviles de baja gama
✅ Si te obsesiona el performance (como a nosotros 😄)

❌ No ideal si:

* ya tienes una app React gigante
* necesitas librerías que dependen mucho del estado global clásico

---

## Relación con lo que tú haces 👀

Si ya tienes un background en:

* **React / Next**
* **infraestructura**
* **apps gubernamentales**

👉 Qwik es **muy buena opción** para:

* portales institucionales
* sitios informativos
* trámites públicos
* apps que deben cargar rápido incluso en zonas con mala conexión
