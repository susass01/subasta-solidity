# **Subasta en Solidity**

Este contrato implementa una subasta en la blockchain Ethereum usando Solidity.

## **Descripción**

Permite a los usuarios ofertar por un artículo en subasta cumpliendo condiciones como superar al menos en un 5% la oferta actual. La subasta tiene una duración determinada y se extiende si hay ofertas en los últimos 10 minutos.

## **Funciones**

* ## **Constructor**

  Inicializa la subasta con:

- Duración en minutos.  
- Asigna al owner (dueño del contrato).


* ### **Ofertar()**

  Acepta una oferta si:

- Es mayor en al menos 5% a la actual.  
- La subasta sigue activa.  
- El tiempo se extiende si la oferta se hace en los últimos 10 minutos.


* ### **MostrarGanador()**

  Devuelve:

- Dirección del ganador.  
- Valor de la mayor oferta.


* ### **MostrarOfertas()**

  Devuelve:

- Lista de participantes.  
- Montos ofertados por cada uno.


* ### **FinalizarSubasta()**

Solo la puede llamar el owner.

Devuelve:

- El 98% de la oferta ganadora al owner.  
- El 100% del saldo a los no ganadores.

* ### **ReembolsoParcial()**

  Permite retirar el exceso depositado por encima de la última oferta válida durante la subasta.


## **Lógica de TiempoExtendido:**

* Si una oferta válida se realiza dentro de los últimos 10 minutos:

- Se añaden 10 minutos a tiempoFinal.

**Variables**

* owner: Dirección que despliega el contrato.

* mayorOferente: Dirección con la mayor oferta.

* mayorOferta: Valor de la mayor oferta.

* tiempoFinal: Timestamp de fin de subasta.

* tiempoExtendido: 10 minutos que se agregan al tiempoFinal

* comision: Porcentaje que se descuenta (2%).

* ofertas: Mapping de dirección a estructura Oferta.

* participantes: Lista de direcciones que han ofertado.


## **Eventos**

* NuevaOferta: Nueva oferta registrada.

* FinalSubasta: Se declara un ganador.

* ReembolsoParcial: Se devuelve el exceso de fondos.

 **Archivos del Repositorio**

* Subasta.sol: Código fuente del contrato inteligente.

* README.md: Documentación y descripción funcional.

---

