void main(List<String> args) {
  dynamic typeInference = 'World';
  // Type is inferred by compiler
  // value can be changed to value of ANY type
  // dangerous / bad practice
  typeInference = 23; // type changed to int
  print('Hello ' + (typeInference * 2).toString());
  typeInference = 'wat?'; // type changed to String
  print('Hello ' + (typeInference * 2).toString()); // result is nonsense
}
