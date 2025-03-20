import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PedidoService } from '../pedido/pedido.service';
import { Bebida } from './bebida.model';
import { Pizza } from './pizza.model';
import { ProdutosService } from './produtos.service';
import { MatIconModule } from '@angular/material/icon';
import { MatTabsModule } from '@angular/material/tabs';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-content',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatTabsModule,
    MatCardModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './content.component.html',
  styleUrls: ['./content.component.css']
})
export class ContentComponent implements OnInit {

  pizzasArray: Pizza[] = [];
  bebidasArray: Bebida[] = [];

  constructor(private produtosService: ProdutosService, private pedidoService: PedidoService) { }

  ngOnInit(): void {
    this.getPizzas();
  }

  getPizzas() {
    this.produtosService.getProdutos().subscribe(data => {
      this.pizzasArray = data.pizzas;
      this.bebidasArray = data.bebidas;
    });
  }

  addPizzaPedido(id: number) {
    this.pizzasArray.forEach((value)=> {
      if(value.id === id){
        this.pedidoService.getPedidoValues(value.name, value.price);
        this.pedidoService.openSnackBar('Pizza adicionada!');
      }
    });
  }

  addBebidaPedido(id: number) {
    this.bebidasArray.forEach((value)=> {
      if(value.id === id){
        this.pedidoService.getPedidoValues(`${value.name} ${value.volume}`, value.price);
        this.pedidoService.openSnackBar('Bebida adicionada!');
      }
    });
  }
}
