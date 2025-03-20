import {Component} from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
import { MatDialog } from '@angular/material/dialog';
import { PedidoDialogComponent } from './pedido-dialog/pedido-dialog.component';

@Component({
  selector: 'app-pedido',
  standalone: true,
  imports: [MatIconModule],
  templateUrl: './pedido.component.html',
  styleUrls: ['./pedido.component.css']
})
export class PedidoComponent {
  constructor(public dialog: MatDialog) {}

  openPedido() {
    const dialogRef = this.dialog.open(PedidoDialogComponent);
    dialogRef.afterClosed().subscribe(result => {});
  }
}
