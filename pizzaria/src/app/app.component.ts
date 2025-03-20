import { Component } from '@angular/core';
import { HeaderComponent } from './components/template/header/header.component';
import { ContentComponent } from './components/template/content/content.component';
import { FooterComponent } from './components/template/footer/footer.component';
import { PedidoComponent } from './components/template/pedido/pedido.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [HeaderComponent, ContentComponent, FooterComponent, PedidoComponent],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'Pizzaria';
}
