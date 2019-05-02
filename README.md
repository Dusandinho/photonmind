# photonmind
Accelerate and automate the design of photonic integrated circuits with machine learning.

## About
The PhotonMind platform creates compact, flexible models of photonic devices using numerically solved electromagnetic data and deep artificial neural networks. This allows for orders-of-magnitude faster calculations for device-level optimizations and system-level simulations. PhotonMind is written in MATLAB and uses Lumerical FDTD for backend data acquisition.

## Getting Started
The development process is broken up into three components: data acquisition, model training, and device optimization. In this guide, we will model and design a simple 1D silicon-on-insulator grating coupler.

### Data acquisition
We first create a new `Data.m` object to automate the acquisition of training data. Note that `FILE_PATH` is the path of your Lumerical FDTD simulation file.

```
>> gc_data = Data(FILE_PATH)

gc_data =

  Data with properties:

    file_name: FILE_PATH
       inputs: [0×0 struct]
      outputs: [0×0 struct]
     examples: [0×0 struct]
```

An artificial neural network can learn the relationship between any set of inputs and outputs. We define the inputs as the etch depth, pitch, and duty cycle of the grating coupler; and the output as the transmission spectrum at the waveguide. Defining a new input or output is as simple as calling the appropriate method with the name of the object in the simulation file, the desired attribute, and, for the case of an input, a range in which to acquire data from.

```
>> gc_data.add_input('grating_coupler_2D', 'etch depth', [0 0.22e-6]);
>> gc_data.add_input('grating_coupler_2D', 'pitch', [0.5e-6 0.8e-6]);
>> gc_data.add_input('grating_coupler_2D', 'duty cycle', [0.1 0.9e-6]);
>> gc_data.add_output('FDTD::ports::port 2", "T', 'monitor.T');
```

We are already ready to acquire training data. We use the uniform acquirer, which sweeps through every combination of inputs for a given step size.

```
>> gc_data.get_examples_uniform(8)
This will run 512 simulations. Proceed? Y/N: y
```

We wait a few hours, and `gc_data` is filled with 512 training examples. Each example carries the features (inputs) and labels (outputs) of a single simulation.

```
>> gc_data

gc_data =

  Data with properties:

    file_name: FILE_PATH
       inputs: [1×3 struct]
      outputs: [1×1 struct]
     examples: [1×512 struct]
```

Before moving on, we randomize the order of the data so as to not introduce bias to our model.

```
>> gc_data.shuffle
```

### Model training
The `Mind.m` class is what we'll use to train the deep neural models of our photonic devices. We can create a new model based on `gc_data`.

```
>> gc = Mind(gc_data, [5 5 5], 'Adam', [0.7 0.3])

gc =

  Mind with properties:

              data: [1×1 Data]
          examples: [1×1 struct]
            layers: [1×5 Layer]
           weights: {[3×5 double]  [5×5 double]  [5×5 double]  [5×50 double]}
            biases: {1×4 cell}
             ratio: [0.7000 0.3000]
       sample_size: 358
        batch_size: 358
         optimizer: [1×1 Optimizer]
    feature_ranges: [2×3 double]
      label_ranges: [2×50 double]
```

Immediately, we can start to train the model for a given number of iterations.

```
>> gc.train(1000);
```

We reach a validation error of X%—not bad! This model can be of course improved on by playing around with different modelling parameters. With our current model, we can predict the output of the device.

### Device optimization

## License
This project is licensed under the Apache-2.0 License - see the [LICENSE](LICENSE) file for details
