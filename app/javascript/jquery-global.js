// https://stackoverflow.com/questions/35358625/jquery-is-not-defined-when-use-es6-import
import jquery from 'jquery';

window.jQuery = jquery;
window.$ = jquery;
