import { Component } from '@angular/core';
import {PackageService} from './_services/package.service';
import {environment} from '../environments/environment';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {

  environment = environment;

  constructor(
    public packageServive: PackageService
  ) {}


  title = 'hello-world';

  doError() {
    throw new Error('This is an error');
  }
}
