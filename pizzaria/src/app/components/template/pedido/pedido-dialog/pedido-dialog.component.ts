import { CommonModule } from '@angular/common';
import { PedidoService } from './../pedido.service';
import { Component, OnInit } from '@angular/core';
import { PedidoFormComponent } from '../pedido-form/pedido-form.component';
import { MatDialog } from '@angular/material/dialog';
import { MatTableModule } from '@angular/material/table';
import { MatIconModule } from '@angular/material/icon';
import { MatDialogModule } from '@angular/material/dialog';

@Component({
  selector: 'app-pedido-dialog',
  standalone: true,
  imports: [
    CommonModule,
    MatTableModule,
    MatIconModule,
    MatDialogModule
  ],
  templateUrl: './pedido-dialog.component.html',
  styleUrls: ['./pedido-dialog.component.css']
})
export class PedidoDialogComponent implements OnInit {

  transactions: any[] = [];

  constructor(public dialog: MatDialog, private pedidoService: PedidoService) { }

  displayedColumns: string[] = ['item', 'price', 'action'];

  ngOnInit(): void {
    this.transactions = this.pedidoService.transactions;
  }

  getTotalPrice() {
    return this.transactions.map(t => t.price).reduce((acc, value) => acc + value, 0);
  }

  openPedidoForm(): void {

    const pedidoString = this.transactions.map(obj => {
      return `(${obj.item}=${obj.price})`;
    }).join(', ');

    console.log(pedidoString);

    this.dialog.open(PedidoFormComponent, {
      data: { pedidoString }
    });
  }

  removerItem(num: number) {
    this.pedidoService.transactions.splice(num, 1);
    this.pedidoService.openSnackBar('Item removido!');
  }

  removerPedido() {
    this.pedidoService.transactions = [];
    this.pedidoService.openSnackBar('Pedido removido!');
  }
}
