"""
Tor Proxy Client for Anonymous Web Scraping
Provides secure, anonymous connections through the Tor network
"""

import logging
import requests
import socks
import socket
from typing import Optional, Dict, Any
from django.conf import settings
from stem import Signal
from stem.control import Controller

logger = logging.getLogger(__name__)


class TorClient:
    """Client for making requests through Tor network"""
    
    def __init__(self):
        self.proxy_host = settings.TOR_PROXY_HOST
        self.proxy_port = settings.TOR_PROXY_PORT
        self.control_port = settings.TOR_CONTROL_PORT
        self.password = settings.TOR_PASSWORD
        self.session = None
        self._setup_session()
    
    def _setup_session(self):
        """Setup requests session with Tor proxy"""
        self.session = requests.Session()
        self.session.proxies = {
            'http': f'socks5h://{self.proxy_host}:{self.proxy_port}',
            'https': f'socks5h://{self.proxy_host}:{self.proxy_port}',
        }
        logger.info(f"Tor session configured with proxy {self.proxy_host}:{self.proxy_port}")
    
    def get_new_identity(self) -> bool:
        """
        Request a new Tor identity (new IP address)
        Returns True if successful, False otherwise
        """
        try:
            with Controller.from_port(port=self.control_port) as controller:
                if self.password:
                    controller.authenticate(password=self.password)
                else:
                    controller.authenticate()
                
                controller.signal(Signal.NEWNYM)
                logger.info("Successfully requested new Tor identity")
                return True
        except Exception as e:
            logger.error(f"Failed to get new Tor identity: {e}")
            return False
    
    def get(self, url: str, headers: Optional[Dict] = None, timeout: int = 30) -> Optional[requests.Response]:
        """
        Make GET request through Tor
        
        Args:
            url: Target URL
            headers: Optional HTTP headers
            timeout: Request timeout in seconds
            
        Returns:
            Response object or None if failed
        """
        try:
            if headers is None:
                headers = self._get_default_headers()
            
            response = self.session.get(url, headers=headers, timeout=timeout)
            logger.debug(f"GET {url} - Status: {response.status_code}")
            return response
        except Exception as e:
            logger.error(f"Tor GET request failed for {url}: {e}")
            return None
    
    def post(self, url: str, data: Optional[Dict] = None, json: Optional[Dict] = None,
             headers: Optional[Dict] = None, timeout: int = 30) -> Optional[requests.Response]:
        """
        Make POST request through Tor
        
        Args:
            url: Target URL
            data: Form data
            json: JSON data
            headers: Optional HTTP headers
            timeout: Request timeout in seconds
            
        Returns:
            Response object or None if failed
        """
        try:
            if headers is None:
                headers = self._get_default_headers()
            
            response = self.session.post(url, data=data, json=json, headers=headers, timeout=timeout)
            logger.debug(f"POST {url} - Status: {response.status_code}")
            return response
        except Exception as e:
            logger.error(f"Tor POST request failed for {url}: {e}")
            return None
    
    def check_tor_connection(self) -> Dict[str, Any]:
        """
        Check if Tor connection is working
        
        Returns:
            Dict with connection status and IP information
        """
        try:
            # Check Tor IP
            response = self.get('https://check.torproject.org/api/ip', timeout=10)
            if response and response.status_code == 200:
                data = response.json()
                return {
                    'connected': data.get('IsTor', False),
                    'ip': data.get('IP', 'Unknown'),
                    'status': 'success'
                }
            else:
                return {
                    'connected': False,
                    'status': 'failed',
                    'error': 'Could not reach Tor check service'
                }
        except Exception as e:
            logger.error(f"Tor connection check failed: {e}")
            return {
                'connected': False,
                'status': 'error',
                'error': str(e)
            }
    
    def _get_default_headers(self) -> Dict[str, str]:
        """Get default headers for requests"""
        import random
        user_agent = random.choice(settings.SCRAPING_USER_AGENTS)
        return {
            'User-Agent': user_agent,
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        }
    
    def close(self):
        """Close the session"""
        if self.session:
            self.session.close()
            logger.info("Tor session closed")


class TorConnectionManager:
    """Manager for Tor connections with rotation"""
    
    def __init__(self, rotation_interval: int = 10):
        """
        Args:
            rotation_interval: Number of requests before rotating identity
        """
        self.client = TorClient()
        self.rotation_interval = rotation_interval
        self.request_count = 0
    
    def get(self, url: str, **kwargs) -> Optional[requests.Response]:
        """Make GET request with automatic identity rotation"""
        self._check_rotation()
        return self.client.get(url, **kwargs)
    
    def post(self, url: str, **kwargs) -> Optional[requests.Response]:
        """Make POST request with automatic identity rotation"""
        self._check_rotation()
        return self.client.post(url, **kwargs)
    
    def _check_rotation(self):
        """Check if identity rotation is needed"""
        self.request_count += 1
        if self.request_count >= self.rotation_interval:
            logger.info(f"Rotating Tor identity after {self.request_count} requests")
            self.client.get_new_identity()
            self.request_count = 0
    
    def verify_connection(self) -> bool:
        """Verify Tor connection is working"""
        result = self.client.check_tor_connection()
        if result['connected']:
            logger.info(f"Tor connection verified. IP: {result['ip']}")
            return True
        else:
            logger.error(f"Tor connection failed: {result.get('error', 'Unknown error')}")
            return False
    
    def close(self):
        """Close the connection manager"""
        self.client.close()


# Global Tor client instance
_tor_manager = None


def get_tor_manager() -> TorConnectionManager:
    """Get or create global Tor manager instance"""
    global _tor_manager
    if _tor_manager is None:
        _tor_manager = TorConnectionManager()
    return _tor_manager


def close_tor_manager():
    """Close global Tor manager"""
    global _tor_manager
    if _tor_manager:
        _tor_manager.close()
        _tor_manager = None
