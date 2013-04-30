Este proyecto es un proyecto escrito es objetive-c, no encontré la forma de escribir una app con Html5 y JS que pudiera mantener un servicio latente de geolocalizacion y anales de geocercas en background dentro de iOS.

Clases impotentes para extender:

TTLocationHandler : creada por Dean Davids, esta clase implementa los servicios de posicionamiento definidos por el LocationManager de iOS, es una implementación limpia y concreta del servicio de posicionamiento.

LMRegion: escribí esta clase ya que los delegados de regiones en iOS presentan muchos problemas al ser implementados en diferentes versiones.

LMtrackerRegion: esta clase define los métodos que interactuan con el servidor, en mi caso escribí una rest que recibe los datos de posiciones, también definí métodos para poder registrar geocercas y determinar si un usuario sale o no de una, esta clase también define los metodos de envío de peticiones y varios cálculos entre puntos, como distancias,velocidades, ángulos entre otros.

Gracias. Si estas interesado en mejorar este trabajo, tus pulla son bien recibidos.


