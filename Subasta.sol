// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Subasta {
    //Inicializo con los parametros necesarios para la subasta
    address public owner;
    uint public duracionSubasta;
    uint public tiempoFinal;
    uint public tiempoExtendido = 10 minutes;
    uint public comision = 2; // 2%

    constructor (uint _duracionSubasta){
        owner = msg.sender;
        tiempoFinal = block.timestamp + (_duracionSubasta * 1 minutes);
    }

    address public mayorOferente;
    uint public mayorOferta;

    struct Oferta {
        uint valorTotal;
        uint ultimaOfertaValida;
    }

    mapping(address => Oferta) public ofertas; //Accedo a las direcciones de las ofertas hechas
    address[] public participantes; //Los declaro como Array porque seran varios participantes
    bool public subastaFinalizada;

//Necesito dos eventos uno para  una nueva oferta y otro para indicar la finalizacion de la subasta
    event NuevaOferta(address indexed oferente, uint valor);
    event FinalSubasta(address oferenteganador, uint valorGanadora);

    //Utilizo el modificador para calcular el tiempo de finalizar la subasta
    modifier mientrasSubastaActiva() {
        require(block.timestamp < tiempoFinal && !subastaFinalizada, "La subasta ha finalizado.");
        _;
    }

//Este modifier se utilizara para evitar que se pueda modificar el tiempo de la subasta si ya ha sido finalizada
    modifier soloOwner() {
        require(msg.sender == owner, "Solo el propietario puede ejecutar esta funcion.");
        _;
    }


    //Funcion para ofertar
function ofertar() external payable mientrasSubastaActiva {
        require(msg.value > 0, "Debe enviar un monto positivo.");
        uint nuevaOferta = ofertas[msg.sender].valorTotal + msg.value; //Total acumulado ofertado por el oferente
        uint minOferta = mayorOferta + (mayorOferta * 5 / 100); //El importe que se debe superar para una nueva oferta

        require(nuevaOferta >= minOferta || mayorOferta == 0, "La oferta debe superar en al menos 5% la actual."); //Validacion de la nueva oferta

        if (ofertas[msg.sender].valorTotal == 0) { //Si el usuario no ha participado lo agrega al array
            participantes.push(msg.sender);
        }

        //Se actualiza el registro del usuario

        ofertas[msg.sender].valorTotal = nuevaOferta;
        ofertas[msg.sender].ultimaOfertaValida = nuevaOferta;

        //Se actualiza las valiables con el mayor oferente
        mayorOferente = msg.sender;
        mayorOferta = nuevaOferta;

        // Se extiende el tiempo de la subasta si la oferta fue hecha en los últimos 10 minutos
        if (tiempoFinal - block.timestamp <= 10 minutes) {
            tiempoFinal += tiempoExtendido;
        }

        emit NuevaOferta(msg.sender, nuevaOferta); //Evento que notifica que se hizo una nueva oferta
    }

    //Funcion para mostrar quien va ganando la subasta y con qué monto
    function mostrarGanador() external view returns (address, uint) {
        return (mayorOferente, mayorOferta);
    }

    function mostrarOfertas() external view returns (address[] memory, uint[] memory) {
        uint[] memory montos = new uint[](participantes.length); //Array de montos con el mismo tamaño del array de participantes
        for (uint i = 0; i < participantes.length; i++) { //Se recorre todos los participantes para completar el array de montos
            montos[i] = ofertas[participantes[i]].valorTotal;
        }
        return (participantes, montos); //Retorna los valores de participantes y los montos de cada uno
    }

    function finalizarSubasta() external soloOwner { //Solo el owner puede llamar la funcion
        require(!subastaFinalizada, "La subasta ya ha sido finalizada."); //Verifica que la subasta no haya sido finalizada
        require(block.timestamp >= tiempoFinal, "La subasta aun esta activa."); //Verifica que si el tiempo ya termino

        subastaFinalizada = true;

        uint totalGanador = ofertas[mayorOferente].valorTotal;
        uint comisionValor = (totalGanador * comision) / 100;
        uint montoOwner = totalGanador - comisionValor;

        //Se transfiere el 98% al owner que es la ganancia
        payable(owner).transfer(montoOwner);

        //Se reembolsa a lo que no ganaron
        for (uint i = 0; i < participantes.length; i++) {
            address participante = participantes[i];
            if (participante != mayorOferente) {
                uint monto = ofertas[participante].valorTotal;
                if (monto > 0){
                payable(participante).transfer(monto);
                }
            }
        }

        emit FinalSubasta(mayorOferente, mayorOferta);
    }

    event ReembolsoParcial(address indexed participante, uint monto); //Evento para notificar que se hizo un reembolso

    function reembolsoParcial() external { //Cualquier usuario puede recuperar su saldo
        require(ofertas[msg.sender].valorTotal > 0, "No tiene fondos depositados."); //Verifica que haya realizado una oferta
        uint reembolso= ofertas[msg.sender].valorTotal - ofertas[msg.sender].ultimaOfertaValida; //Se hace el calculo del deposito del usuario se la ultima oferta valida
        require(reembolso > 0, "No hay monto reembolsable."); //Si no hay diferencia entre los montos ofertado no se devuelve nada
        ofertas[msg.sender].valorTotal = ofertas[msg.sender].ultimaOfertaValida; //Se actualiza el valor registrado a la ultima oferta valida
        payable(msg.sender).transfer(reembolso); //Se tranfiere lo que quedo al usuario
    
    
    emit ReembolsoParcial(msg.sender, reembolso);
    
    }

}