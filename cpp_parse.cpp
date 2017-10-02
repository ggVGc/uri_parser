#include <stdio.h>
#include <string>
#include <iostream>
#include <functional>

using std::string;

struct URIInfo{
  string scheme;
  string host;
  string port;
  string user;
  string pass;
  string path;
  string query;
  string fragment;
};


typedef string::const_iterator (*ParseFun)(const string::const_iterator startIter, const string::const_iterator &endIter, URIInfo &outInfo);

enum class ParseStageID{
  Scheme
  ,UserInfo
  ,Host
  ,Port
  ,Path
  ,Done
};


ParseStageID nextStageID(const ParseStageID &stageID){
  switch (stageID) {
    case ParseStageID::Scheme: return ParseStageID::UserInfo;
    case ParseStageID::UserInfo: return ParseStageID::Host;
    case ParseStageID::Host: return ParseStageID::Port;
    case ParseStageID::Port: return ParseStageID::Path;
    case ParseStageID::Path: return ParseStageID::Done;
    default: return ParseStageID::Done;
  }
}


string::const_iterator parseScheme(const string::const_iterator startIter, const string::const_iterator &endIter, URIInfo &outInfo){
  string::const_iterator curIter = startIter;
  while(curIter != endIter){
    const auto c = *(curIter++);
    if(c == '/'){
      break;
    }else if(c == ':'){
      outInfo.scheme = string(startIter, curIter-1);
      return curIter;
    }
  }

  return startIter;
}


struct ParserRet{
  ParserRet(string::const_iterator iter):finishedParse(true), iter(iter){}

  static ParserRet Continue(){ return ParserRet();}

  const bool finishedParse;
  const string::const_iterator iter;

  private:
    ParserRet() : finishedParse(false){}
};


typedef std::function<ParserRet(const char c, string::const_iterator curIter, const bool isEnd)> ParserBody;

// Convenience function for running parsing functions
// Handles iteration and return/break conditions
string::const_iterator runParser(const string::const_iterator startIter, const string::const_iterator &endIter, ParserBody parser){
  string::const_iterator curIter = startIter;
  while(curIter != endIter){
    const auto c = *(curIter++);
    const auto ret = parser(c, curIter, curIter == endIter);
    if (ret.finishedParse) {
      return ret.iter;
    }
  }
  return startIter;
}


string::const_iterator parseHost(const string::const_iterator startIter, const string::const_iterator &endIter, URIInfo &info){
  string::const_iterator curIter = startIter;
  const char first = startIter != endIter ? (*startIter) : ' ';
  const char second = startIter+1 != endIter ? *(startIter+1) : ' ';

  // host has to start with either // or @, and they should be ignored in output
  int offset = 0;
  if(first == '/' && second == '/'){
    offset = 2;
  }else if(first == '@'){
    offset = 1;
  }

  // Only run parser if host field starts with valid characters (e.g offset is non-zero)
  if(offset == 0){
    return startIter;
  }

  return runParser(startIter+offset, endIter,
    [startIter, &info, offset] (const char c, string::const_iterator curIter, const bool isEnd){
      if(c == '/' || c == ':' || isEnd){
        if(c == '/'){
          curIter--;
        }
        auto retIter = curIter;
        if(c == ':'){
          curIter--;
        }
        info.host = string(startIter+offset, curIter);
        return ParserRet(retIter);
      }
      return ParserRet::Continue();
  });
}


bool isDigit(const char &c){
  return c=='1'||c=='2'||c=='3'||c=='4'||c=='5'||c=='6'||c=='7'||c=='8'||c=='9'||c=='0';
}


string::const_iterator parsePort(const string::const_iterator startIter, const string::const_iterator &endIter, URIInfo &info){
  return runParser(startIter, endIter,
    [startIter, &info] (const char c, string::const_iterator curIter, const bool isEnd){
      if(!isDigit(c) || isEnd){
        if(!isEnd){
          curIter--;
        }
        info.port = string(startIter, curIter);
        return ParserRet(curIter);
      }
      return ParserRet::Continue();
    });
}


string::const_iterator parsePath(const string::const_iterator startIter, const string::const_iterator &endIter, URIInfo &info){
  return runParser(startIter, endIter,
    [startIter, &info] (const char c, string::const_iterator curIter, const bool isEnd){
      if(c=='?' || c=='#' || isEnd){
        if (!isEnd) {
          curIter--;
        }
        info.path = string(startIter, curIter);
        return ParserRet(curIter);
      }
      return ParserRet::Continue();
  });
}



string::const_iterator parseUserInfo(const string::const_iterator startIter, const string::const_iterator &endIter, URIInfo &info){
  string::const_iterator curIter = startIter;
   int slashCount = 0;
   while(curIter != endIter && *curIter == '/'){
    slashCount++;
    curIter++;
   }

  if(slashCount > 2){
    return startIter;
  }

  string::const_iterator colonPos = endIter;
  return runParser(startIter, endIter,
    [startIter, &info, slashCount, &colonPos, endIter] (const char c, string::const_iterator curIter, const bool isEnd){
      if(c==':'){
        colonPos = curIter;
      }else if(c=='@' && colonPos != endIter){
        info.user = string(startIter+slashCount, colonPos-1);
        info.pass = string(colonPos, curIter-1);
        return ParserRet(curIter-1);
      }
      return ParserRet::Continue();
  });
}


ParseFun getParseFun(const ParseStageID &stageID){
  switch (stageID) {
    case ParseStageID::Scheme: return parseScheme;
    case ParseStageID::UserInfo: return parseUserInfo;
    case ParseStageID::Host: return parseHost;
    case ParseStageID::Port: return parsePort;
    case ParseStageID::Path: return parsePath;
    default: return nullptr;
  }
}


URIInfo parseURI(const string &input){
  URIInfo info;
  ParseStageID stage = ParseStageID::Scheme;

  auto iter = input.begin();
  while(iter != input.end()){
    iter = getParseFun(stage)(iter, input.end(), info);
    stage = nextStageID(stage);
  }
  return info;
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


void printResult(const URIInfo &info){
  std::cout << "Map(" << std::endl;
  printResultEntry("scheme", emptyToNull(info.scheme));
  printResultEntry("host", emptyToNull(info.host));
  printResultEntry("port", info.port.empty()?"-1":info.port);
  printResultEntry("user", emptyToNull(info.user));
  printResultEntry("pass", emptyToNull(info.pass));
  printResultEntry("path", emptyToNull(info.path));
  printResultEntry("query", emptyToNull(info.query));
  printResultEntry("fragment", emptyToNull(info.fragment));
  std::cout << ")" << std::endl;
}


int main(int argc, char *argv[]){
  string input;
  getline(std::cin, input);

  // Split off query and fragment first
  string body = input;
  string query = "";
  string fragment = "";

  const auto fragmentSepInd = input.find("#");
  if (fragmentSepInd != string::npos) {
    fragment = input.substr(fragmentSepInd+1);
    body = input.substr(0,fragmentSepInd);
  }

  const auto querySepInd = body.find("?");
  if (querySepInd != string::npos) {
    query = body.substr(querySepInd+1);
    body = body.substr(0,querySepInd);
  }
    
  URIInfo info = parseURI(body);
  info.query = query;
  info.fragment = fragment;

  printResult(info);
  return 0;
}


