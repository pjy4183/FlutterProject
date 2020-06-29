import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weatherwithu2/weatherModel.dart';
import 'package:weatherwithu2/weatherRepo.dart';

class WeatherEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class FetchWeather extends WeatherEvent {
  final _city;

  FetchWeather(this._city);

  @override
  List<Object> get props => [_city];
  
}

class ResetWeather extends WeatherEvent {

}

class WeatherState extends Equatable{
  @override
  List<Object> get props => [];
}

class WeatherIsNotSearch extends WeatherState {
  
}

class WeatherIsLoading extends WeatherState {
  
}

class WeatherIsLoaded extends WeatherState {
  final _weather;
  WeatherModel get getWeather => _weather;
  WeatherIsLoaded(this._weather);
  @override
  List<Object> get props => [_weather];
}

class WeatherIsNotLoaded extends WeatherState {
  
}

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  
  WeatherRepo weatherRepo;

  WeatherBloc(this.weatherRepo);
  
  @override
  // TODO: implement initialState
  WeatherState get initialState => WeatherIsNotSearch();

  @override
  Stream<WeatherState> mapEventToState(WeatherEvent event) async*{
    // TODO: implement mapEventToState
    if (event is FetchWeather) {
      yield WeatherIsLoading();
      try{
        WeatherModel weather = await weatherRepo.getWeather(event._city);
        yield WeatherIsLoaded(weather);
      }catch(_) {
        yield WeatherIsNotLoaded();
      }
    } else if(event is ResetWeather) {
      yield WeatherIsNotSearch();
    }
  }
  
}