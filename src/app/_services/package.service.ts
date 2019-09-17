import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { Package } from '../_models/Package';

declare var require: any;
const pkg = require('../../../package.json');

@Injectable({
  providedIn: 'root'
})
export class PackageService {

  get(): Observable<Package> {
    return of(pkg);
  }

  // Todo(A): Let's get rid of this, we should just refactor `Get()`
  getSync(): Package {
    return pkg;
  }

}
