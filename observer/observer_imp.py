from abc import ABC, abstractmethod
from typing import List, Any

class Observer(ABC):
    @abstractmethod
    def update(self, subject: 'Subject', data: Any = None) -> None:
        """Called when the subject's state changes."""
        pass    

# Abstract Subject interface
class Subject(ABC):
    """Abstract base class for subjects (observables)."""
    
    def __init__(self):
        self._observers: List[Observer] = []
    
    def attach(self, observer: Observer) -> None:
        """Attach an observer to the subject."""
        if observer not in self._observers:
            self._observers.append(observer)
            print(f"Observer {observer.__class__.__name__} attached")
    
    def detach(self, observer: Observer) -> None:
        """Detach an observer from the subject."""
        if observer in self._observers:
            self._observers.remove(observer)
            print(f"Observer {observer.__class__.__name__} detached")
    
    def notify(self, data: Any = None) -> None:
        """Notify all observers about state change."""
        print(f"Notifying {len(self._observers)} observers...")
        for observer in self._observers:
            observer.update(self, data)


# Concrete Subject implementation
class WeatherStation(Subject):
    """Concrete subject that represents a weather station."""
    
    def __init__(self):
        super().__init__()
        self._temperature: float = 0.0
        self._humidity: float = 0.0
        self._pressure: float = 0.0
    
    @property
    def temperature(self) -> float:
        return self._temperature
    
    @property
    def humidity(self) -> float:
        return self._humidity
    
    @property
    def pressure(self) -> float:
        return self._pressure
    
    def set_measurements(self, temperature: float, humidity: float, pressure: float) -> None:
        """Update weather measurements and notify observers."""
        self._temperature = temperature
        self._humidity = humidity
        self._pressure = pressure
        self.measurements_changed()
    
    def measurements_changed(self) -> None:
        """Called when measurements change."""
        weather_data = {
            'temperature': self._temperature,
            'humidity': self._humidity,
            'pressure': self._pressure
        }
        self.notify(weather_data)

# Concrete Observer implementations
class CurrentConditionsDisplay(Observer):
    """Observer that displays current weather conditions."""
    
    def __init__(self, name: str = "Current Conditions Display"):
        self.name = name
    
    def update(self, subject: Subject, data: Any = None) -> None:
        """Update display with new weather data."""
        if isinstance(subject, WeatherStation) and data:
            print(f"\n{self.name}:")
            print(f"  Temperature: {data['temperature']}°C")
            print(f"  Humidity: {data['humidity']}%")
            print(f"  Pressure: {data['pressure']} hPa")


class StatisticsDisplay(Observer):
    """Observer that displays weather statistics."""
    
    def __init__(self):
        self.name = "Statistics Display"
        self._temperature_readings: List[float] = []
    
    def update(self, subject: Subject, data: Any = None) -> None:
        """Update statistics with new weather data."""
        if isinstance(subject, WeatherStation) and data:
            self._temperature_readings.append(data['temperature'])
            avg_temp = sum(self._temperature_readings) / len(self._temperature_readings)
            min_temp = min(self._temperature_readings)
            max_temp = max(self._temperature_readings)
            
            print(f"\n{self.name}:")
            print(f"  Avg Temperature: {avg_temp:.1f}°C")
            print(f"  Min Temperature: {min_temp}°C")
            print(f"  Max Temperature: {max_temp}°C")


class ForecastDisplay(Observer):
    """Observer that displays weather forecast."""
    
    def __init__(self):
        self.name = "Forecast Display"
        self._last_pressure = 0.0
    
    def update(self, subject: Subject, data: Any = None) -> None:
        """Update forecast based on pressure changes."""
        if isinstance(subject, WeatherStation) and data:
            current_pressure = data['pressure']
            
            if current_pressure > self._last_pressure:
                forecast = "Weather improving!"
            elif current_pressure < self._last_pressure:
                forecast = "Weather worsening!"
            else:
                forecast = "Weather unchanged"
            
            print(f"\n{self.name}:")
            print(f"  Forecast: {forecast}")
            
            self._last_pressure = current_pressure
def main():
    """Demonstration of the Observer pattern."""
    
    print("=== Observer Pattern Demo: Weather Station ===")
    
    # Create weather station (subject)
    weather_station = WeatherStation()
    
    # Create observers
    current_display = CurrentConditionsDisplay()
    statistics_display = StatisticsDisplay()
    forecast_display = ForecastDisplay()
    
    # Register observers
    weather_station.attach(current_display)
    weather_station.attach(statistics_display)
    weather_station.attach(forecast_display)
    
    # Simulate weather changes
    print("\n--- Weather Update 1 ---")
    weather_station.set_measurements(25.0, 65.0, 1013.2)
    
    print("\n--- Weather Update 2 ---")
    weather_station.set_measurements(27.5, 70.0, 1015.8)
    
    print("\n--- Weather Update 3 ---")
    weather_station.set_measurements(23.0, 80.0, 1010.1)
    
    # Remove an observer
    print("\n--- Removing Statistics Display ---")
    weather_station.detach(statistics_display)
    
    print("\n--- Weather Update 4 ---")
    weather_station.set_measurements(26.0, 75.0, 1012.5)
    
if __name__ == "__main__":
    main()
