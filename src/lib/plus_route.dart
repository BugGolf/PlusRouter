import 'package:flutter/material.dart';
import 'plus_router_state.dart';

class PlusRoute 
{
  final bool isDefaultPage;
  final String path;
  final Widget Function(PlusRouterState state, Map<String, dynamic> arguments)? builder;
  final Widget? widget;

  PlusRoute({
    required this.path,
    this.builder,
    this.widget,
    this.isDefaultPage = false
  }) : assert((builder == null) != (widget == null)) {
    this.arguments = {};

    if(this.path.length > 0)
      this.segments = this.removeStartsWithSlash(this.path).split("/");

    if(this.segments.isNotEmpty) {
      for(String segment in this.segments) {
        if(this.isParam(segment))
          this.setParam(segment, null);
      }
    }
  }

  Map<String, dynamic> arguments = {};
  List<String> segments = [];
  List<String> locationSegments = [];

  bool isParent = false;
  bool isCurrent = false;

  String get name {
    return "plus_" + this.segments.join("_") + "_page";
  }

  String get location {
    return "/" + this.locationSegments.join("/");
  }

  bool get didPop => this.segments.isNotEmpty;

  /**
   * Remove start with '/' string./
   */
  String removeStartsWithSlash(String location) {
    return location.startsWith("/") ? location.substring(1) : location;
  }

  /**
   * Check is param in segments
   */
  bool isParam(String value) {
    return value.startsWith(":");
  }

  /**
   * Set parameter value
   */
  void setParam(String segment, dynamic value) {
    if(isParam(segment)) {
      String key = segment.substring(1);
      this.arguments[key] = value;
    }
  }

  /**
   * Try parse from URL segments
   */
  bool tryParse(List<String> pathSegments) {
    bool _result = false;
    this.locationSegments = [];
    
    if(pathSegments.isEmpty && this.segments.isEmpty) {
      isCurrent = true;
      return true;
    }

    // Default is false
    this.isParent = false;
    this.isCurrent = false;

    // Check path segments
    // if length = my path length
    // Each all segment find my path is same current route
    if(pathSegments.length >= segments.length) 
    {
      for(int i=0;i<pathSegments.length;i++) 
      {
        String pathSegment = pathSegments[i];
        if(segments.asMap().containsKey(i)) {
          String segment = segments[i];

          // Skip if segment is param.
          if(isParam(segment))
            this.setParam(segment, pathSegment);

          // Stop and then return false
          else if( pathSegment != segment )
            return false;

          this.locationSegments.add(pathSegment);
          _result = true;
        }

        else 
          break;
      }
    }

    if(_result) {
      isParent = pathSegments.length > segments.length;
      isCurrent = pathSegments.length == segments.length;
    }

    return _result;
  }
}