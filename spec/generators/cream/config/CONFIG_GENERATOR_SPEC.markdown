# Cream Config Generator spec Design Notes

The Cream Config generator is very complex and is designed various Session, Permission and Roles aspects encapsulated by Cream.

## Modular architecture

In order to achieve this, a modular Generator approach is used. Each module has responsibility to set up a particular aspect of Cream.
When running the generator, this modular architecture can be leveraged, so that specific parts of the generation process can be run and not others.

## Specs

This also makes it easier to test the functionality of the generator, as a single module can be tested in isolation or in combination with one or more other modules.

  
 