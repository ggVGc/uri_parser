#include <stdio.h>
#include <string>
#include <iostream>

using std::string;

struct Output{
  string scheme;
  string host;
  string port;
  string user;
  string pass;
  string path;
  string query;
  string fragment;
};


struct ParseResult{
  string::const_iterator iter;
  string str;
};


enum class Part{
  Scheme
  ,UserInfo
  ,Host
  ,Port
  ,Path
  ,Done
};


struct ParseState{
  Part curPart = Part::Scheme;
  string accum;
};


Part parseScheme(const string::const_iterator startIter, const string::const_iterator &endIter, ParseResult &ret){
  string::const_iterator curIter = startIter;
  while(curIter != endIter){
    auto c = *(curIter++);
    if(c == '/'){
      break;
    }else if(c == ':'){
      ret.str = string(startIter, curIter-1);
      ret.iter = curIter;
      break;
    }
  }

  return Part::UserInfo;
}


Part parseHost(const string::const_iterator startIter, const string::const_iterator &endIter, ParseResult &ret){
  string::const_iterator curIter = startIter;
  const char first = startIter != endIter ? (*startIter) : ' ';
  const char second = startIter+1 != endIter ? *(startIter+1) : ' ';

  int offset = 0;
  if(first == '/' && second == '/'){
    offset = 2;
  }else if(first == '@'){
    offset = 1;
  }

  if(offset > 0){
    curIter+=offset;
    while(curIter != endIter){
      auto c = *(curIter++);
      if(c == '/' || c == ':' || curIter == endIter){
        if(c == '/'){
          curIter--;
        }
        ret.iter = curIter;
        if(c == ':'){
          curIter--;
        }
        ret.str = string(startIter+offset, curIter);
        break;
      }
    }
  }
  return Part::Port;
}


bool isDigit(const char &c){
  return c=='1'||c=='2'||c=='3'||c=='4'||c=='5'||c=='6'||c=='7'||c=='8'||c=='9'||c=='0';
}


Part parsePort(const string::const_iterator startIter, const string::const_iterator &endIter, ParseResult &ret){
  string::const_iterator curIter = startIter;
  while(curIter != endIter){
    auto c = *(curIter++);
    if(!isDigit(c) || curIter == endIter){
      if(curIter != endIter){
        curIter--;
      }
      ret.iter = curIter;
      ret.str = string(startIter, curIter);
      break;
    }
  }
  return Part::Path;
}


Part parsePath(const string::const_iterator startIter, const string::const_iterator &endIter, ParseResult &ret){
  string::const_iterator curIter = startIter;
  while(curIter != endIter){
    auto c = *(curIter++);
    if(c=='?' || c=='#' || curIter == endIter){
      if (curIter != endIter) {
        curIter--;
      }
      ret.iter = curIter;
      ret.str = string(startIter, curIter);
      break;
    }
  }
  return Part::Done;
}



void parseUserInfo(const string::const_iterator startIter, const string::const_iterator &endIter, string::const_iterator &outIter, string &outUser, string &outPass){
  string::const_iterator curIter = startIter;
  string::const_iterator colonPos = startIter;
  bool foundColon = false;

   int slashes = 0;
   while(curIter != endIter && *curIter == '/'){
    slashes++;
    curIter++;
   }

  while(slashes <= 2 && curIter != endIter){
    auto c = *(curIter++);
    if(c==':'){
      colonPos = curIter;
      foundColon = true;
    }else if(c=='@' && foundColon){
      outIter = curIter-1;
      outUser = string(startIter+slashes, colonPos-1);
      outPass = string(colonPos, curIter-1);
      break;
    }
  }
}


Output parseURI(const string &input){
  Output out;
  ParseState parseState;

  ParseResult parseRes;
  parseRes.iter = input.begin();
  while(parseRes.iter != input.end()){
    parseRes.str = "";
    switch (parseState.curPart) {
      case Part::Scheme:
          parseState.curPart = parseScheme(parseRes.iter, input.end(), parseRes);
          out.scheme = parseRes.str;
        break;
      case Part::UserInfo:
          parseUserInfo(parseRes.iter, input.end(), parseRes.iter, out.user, out.pass);
          parseState.curPart = Part::Host;
        break;
      case Part::Host:
          parseState.curPart = parseHost(parseRes.iter, input.end(), parseRes);
          out.host = parseRes.str;
        break;
      case Part::Port:
          parseState.curPart = parsePort(parseRes.iter, input.end(), parseRes);
          out.port = parseRes.str;
        break;
      case Part::Path:
          parseState.curPart = parsePath(parseRes.iter, input.end(), parseRes);
          out.path = parseRes.str;
        break;
      default:
        parseRes.iter++;
    }
  }
  return out;
}


string emptyToNull(const string &s){
  if (s.empty()) {
    return "null";
  }else{
    return s;
  }
}


void printResultEntry(const string &key, const string &value){
  std::cout << "[" << key << "] => " << value << std::endl;
}


void printResult(const Output &out){
  std::cout << "Map(" << std::endl;
  printResultEntry("scheme", emptyToNull(out.scheme));
  printResultEntry("host", emptyToNull(out.host));
  printResultEntry("port", out.port.empty()?"-1":out.port);
  printResultEntry("user", emptyToNull(out.user));
  printResultEntry("pass", emptyToNull(out.pass));
  printResultEntry("path", emptyToNull(out.path));
  printResultEntry("query", emptyToNull(out.query));
  printResultEntry("fragment", emptyToNull(out.fragment));
  std::cout << ")" << std::endl;
}


int main(int argc, char *argv[]){
  string input;
  getline(std::cin, input);
  string body = input;
  string query = "";
  string fragment = "";
  auto fragmentSepInd = input.find("#");
  if (fragmentSepInd != string::npos) {
    fragment = input.substr(fragmentSepInd+1);
    body = input.substr(0,fragmentSepInd);
  }

  auto querySepInd = body.find("?");
  if (querySepInd != string::npos) {
    query = body.substr(querySepInd+1);
    body = body.substr(0,querySepInd);
  }
    
  Output out = parseURI(body);
  out.query = query;
  out.fragment = fragment;

  printResult(out);
  return 0;
}


